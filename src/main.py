#!/usr/bin/env python3

from __future__ import absolute_import, division, print_function, unicode_literals

import argparse
import collections
import enum
import logging
import multiprocessing
import os
import re
import signal
import subprocess
import sys
import threading
import time
from os import path
from typing import Deque, List, Optional

# default logging config
log = logging.Logger("default", logging.INFO)


class OptimizationLevel(enum.Enum):
    FAST = "fast"
    DEFAULT = "default"
    BRUTE = "brute"
    ULTRA_BRUTE = "ultra-brute"

    def __str__(self):
        return str(self.value)


class Termcode(enum.Enum):
    RESET = "\33[0m"
    GREEN = "\33[32m"
    UP_NLINES = "\33[0A"
    DOWN_NLINES = "\33[0B"
    ERASE_LINE = "\33[2K"

    def __str__(self):
        if sys.stdout.isatty():
            return str(self.value)
        else:
            return ""


# gracefully exit on SIGINT
def signal_handler(signal_name, _):
    log.debug("Signal: %s", signal_name)
    sys.exit(0)


# Find all png files to optimize
def find_images() -> List[str]:
    if not path.exists("/img"):
        log.error("/img must exist")
        sys.exit(1)
    if path.isfile("/img"):
        return ["/img"]
    if not path.isdir("/img"):
        log.error("/img must be file or directory")
        sys.exit(1)

    results = []
    for dir_name, _, file_list in os.walk("/img"):
        results += [path.join(dir_name, x) for x in file_list if re.match(r"^.+\.png$", x)]
    results = [x for x in results if path.isfile(x)]
    results = sorted(results)

    log.debug("Found images: %s\n", "\n".join(f"- {x}" for x in results))

    return results


# This is the class where magic happens
class Worker:
    started_lock = threading.Lock()
    started_queue: Deque[str] = collections.deque()
    finished_lock = threading.Lock()
    finished_queue: Deque[str] = collections.deque()
    kill_progress = False

    # shared state
    input_lock = threading.Lock()
    input_paths: Deque[str]

    def __init__(self, paths: List[str]) -> None:
        self.input_paths = collections.deque(paths)

    # This is a dedicated thread for displaying progress
    def progress_worker(self):
        spinner_parts = ["⌞", "⌟", "⌝", "⌜"]
        spinner_index = 0

        work_indices = dict()  # Dict[str, int]
        work_queue = collections.deque()  # Deque[Tuple[str, bool]]
        first_working_index = 0  # indicates last (the soonest) item to be still procesing

        while True:
            time.sleep(0.15)

            # first copy started items to our temporary queue to not block other threads
            temporary_started_queue = collections.deque()
            with self.started_lock:
                for _ in range(len(self.started_queue)):
                    temporary_started_queue.append(self.started_queue.popleft())

            # save current work items
            for _ in range(len(temporary_started_queue)):
                item = temporary_started_queue.popleft()
                work_indices[item] = len(work_queue)
                work_queue.append((item, True))
                print(item, end="\n")

            # basically show working items in terminal
            for i in range(first_working_index, len(work_queue)):
                if not work_queue[i][1]:
                    continue
                offset_from_last = len(work_queue) - i
                item = re.sub(r"^/img/", "", work_queue[i][0])
                up_command = re.sub(r"0", str(offset_from_last), Termcode.UP_NLINES.value)
                down_command = re.sub(r"0", str(offset_from_last), Termcode.DOWN_NLINES.value)
                print(f"{up_command}\r", end="")
                print(f"{Termcode.ERASE_LINE}\r{item} {spinner_parts[spinner_index]}", end="")
                print(f"{down_command}\r", end="")

            # first copy finished items to our temporary queue to not block other threads
            temporary_finished_queue = collections.deque()
            with self.finished_lock:
                for _ in range(len(self.finished_queue)):
                    temporary_finished_queue.append(self.finished_queue.popleft())

            # process current work items
            for _ in range(len(temporary_finished_queue)):
                item = temporary_finished_queue.popleft()
                work_index = work_indices[item]
                work_queue[work_index] = (item, False)
                if work_index == first_working_index:
                    while len(work_queue) > first_working_index and not work_queue[first_working_index][1]:
                        item = re.sub(r"^/img/", "", work_queue[first_working_index][0])
                        offset_from_last = len(work_queue) - first_working_index
                        up_command = re.sub(r"0", str(offset_from_last), Termcode.UP_NLINES.value)
                        down_command = re.sub(r"0", str(offset_from_last), Termcode.DOWN_NLINES.value)
                        print(f"{up_command}\r", end="")
                        print(
                            f"{Termcode.ERASE_LINE}\r{item} {Termcode.GREEN}✔{Termcode.RESET}",
                            end="",
                        )
                        print(f"{down_command}\r", end="")
                        first_working_index += 1
                else:
                    item = re.sub(r"^/img/", "", work_queue[work_index][0])
                    offset_from_last = len(work_queue) - work_index
                    up_command = re.sub(r"0", str(offset_from_last), Termcode.UP_NLINES.value)
                    down_command = re.sub(r"0", str(offset_from_last), Termcode.DOWN_NLINES.value)
                    print(f"{up_command}\r", end="")
                    print(
                        f"{Termcode.ERASE_LINE}\r{item} {Termcode.GREEN}✔{Termcode.RESET}",
                        end="",
                    )
                    print(f"{down_command}\r", end="")

            spinner_index = (spinner_index + 1) % len(spinner_parts)
            if self.kill_progress:
                break

    def image_worker(self, dry_run: bool, level: OptimizationLevel):
        while True:
            with self.input_lock:
                if len(self.input_paths) == 0:
                    break
                image_path = self.input_paths.popleft()

            with self.started_lock:
                self.started_queue.append(image_path)

            command = ["sh", "main.sh", image_path, level.value]
            if not dry_run:
                subprocess.check_call(command)

            with self.finished_lock:
                self.finished_queue.append(image_path)


def main(argv: Optional[List[str]]):
    signal.signal(signal.SIGINT, signal_handler)
    log.addHandler(logging.StreamHandler(sys.stderr))

    if argv is None:
        argv = sys.argv[1:]

    # parse arguments
    parser = argparse.ArgumentParser(prog="millipng")
    parser.add_argument("-V", "--version", action="version", version="%(prog)s 0.2.2")
    parser.add_argument(
        "-l",
        "--level",
        type=OptimizationLevel,
        choices=list(OptimizationLevel),
        default="default",
        help="Optimization level",
    )
    parser.add_argument("-n", "--dry-run", action="store_true", help="Do not actually modify images")
    parser.add_argument(
        "-j",
        "--jobs",
        type=int,
        default=0,
        help="Number of parallel jobs/threads to run (default is 0 - automatically determine according to current cpu)",
    )
    command_group = parser.add_mutually_exclusive_group()  # disallow using verbose & quiet together
    command_group.add_argument("-v", "--verbose", action="store_true", help="Additional logging output")
    command_group.add_argument("-q", "--quiet", action="store_true", help="Suppress default logging output")
    args = parser.parse_args(argv)

    log.setLevel(logging.INFO)
    if args.verbose:
        log.setLevel(logging.DEBUG)
    if args.quiet:
        log.setLevel(logging.ERROR)

    thread_count = args.jobs
    if thread_count < 0:
        log.error("Thread count can't be negative, got %s", thread_count)
        sys.exit(1)
    elif thread_count == 0:
        # get it dynamically by cpu core count
        thread_count = multiprocessing.cpu_count()
    log.debug("Using %s threads", thread_count)

    worker = Worker(find_images())

    # start this deamon
    progress_work = threading.Thread(target=worker.progress_worker, daemon=True)

    # start threads and wait for finish
    threads = [threading.Thread(target=worker.image_worker, daemon=True, args=[args.dry_run, args.level]) for _ in range(thread_count)]
    for thread in threads:
        thread.start()
    progress_work.start()
    for thread in threads:
        thread.join()

    worker.kill_progress = True
    progress_work.join()


if __name__ == "__main__":
    main(sys.argv[1:])
