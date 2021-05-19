#!/usr/bin/env python

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
from typing import Deque, List, Optional

# default logging config
log = logging.Logger("default", logging.INFO)

# shared state
input_paths = collections.deque()
input_lock = threading.Lock()

started_lock = threading.Lock()
started_queue = collections.deque()
finished_lock = threading.Lock()
finished_queue = collections.deque()
kill_progress = False


class OptimizationLevel(enum.Enum):
    FAST = "fast"
    DEFAULT = "default"
    BRUTE = "brute"
    ULTRA_BRUTE = "ultra-brute"

    def __str__(self):
        return str(self.value)


class Termcode(enum.Enum):
    reset = "\33[0m"
    green = "\33[32m"
    up_nlines = "\33[0A"
    down_nlines = "\33[0B"
    erase_line = "\33[2K"

    def __str__(self):
        if sys.stdout.isatty():
            return str(self.value)
        else:
            return ""


# gracefully exit on SIGINT
def signal_handler(signal):
    log.debug('Signal: %s', signal)
    sys.exit(0)


# Find all png files to optimize
def find_images() -> Deque[str]:
    if not os.path.exists("/img"):
        log.error("/img must exist")
        sys.exit(1)
    if os.path.isfile("/img"):
        return collections.deque(["/img"])
    if not os.path.isdir("/img"):
        log.error("/img must be file or directory")
        sys.exit(1)

    results = []
    for dir_name, _, file_list in os.walk("/img"):
        results += [os.path.join(dir_name, x) for x in file_list if re.match(r"^.+\.png$", x)]
    results = [x for x in results if os.path.isfile(x)]
    results = sorted(results)

    log.debug("Found images: %s\n", "\n".join(f"- {x}" for x in results))

    return collections.deque(results)


# This is a dedicated thread for displaying progress
def progress_worker():
    global started_lock, started_queue, finished_lock, finished_queue

    spinner_parts = ["⌞", "⌟", "⌝", "⌜"]
    spinner_index = 0

    work_indices = dict()  # Dict[str, int]
    work_queue = collections.deque()  # Deque[Tuple[str, bool]]
    first_working_index = 0  # indicates last (the soonest) item to be still procesing

    while True:
        time.sleep(0.15)

        # first copy started items to our temporary queue to not block other threads
        temporary_started_queue = collections.deque()
        with started_lock:
            for _ in range(len(started_queue)):
                temporary_started_queue.append(started_queue.popleft())

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
            up_command = re.sub(r"0", str(offset_from_last), Termcode.up_nlines.value)
            down_command = re.sub(r"0", str(offset_from_last), Termcode.down_nlines.value)
            print(f"{up_command}\r", end="")
            print(f"{Termcode.erase_line}\r{item} {spinner_parts[spinner_index]}", end="")
            print(f"{down_command}\r", end="")

        # first copy finished items to our temporary queue to not block other threads
        temporary_finished_queue = collections.deque()
        with finished_lock:
            for _ in range(len(finished_queue)):
                temporary_finished_queue.append(finished_queue.popleft())

        # process current work items
        for _ in range(len(temporary_finished_queue)):
            item = temporary_finished_queue.popleft()
            work_index = work_indices[item]
            work_queue[work_index] = (item, False)
            if work_index == first_working_index:
                while len(work_queue) > first_working_index and not work_queue[first_working_index][1]:
                    item = re.sub(r"^/img/", "", work_queue[first_working_index][0])
                    offset_from_last = len(work_queue) - first_working_index
                    up_command = re.sub(r"0", str(offset_from_last), Termcode.up_nlines.value)
                    down_command = re.sub(r"0", str(offset_from_last), Termcode.down_nlines.value)
                    print(f"{up_command}\r", end="")
                    print(
                        f"{Termcode.erase_line}\r{item} {Termcode.green}✔{Termcode.reset}",
                        end="",
                    )
                    print(f"{down_command}\r", end="")
                    first_working_index += 1
            else:
                item = re.sub(r"^/img/", "", work_queue[work_index][0])
                offset_from_last = len(work_queue) - work_index
                up_command = re.sub(r"0", str(offset_from_last), Termcode.up_nlines.value)
                down_command = re.sub(r"0", str(offset_from_last), Termcode.down_nlines.value)
                print(f"{up_command}\r", end="")
                print(
                    f"{Termcode.erase_line}\r{item} {Termcode.green}✔{Termcode.reset}",
                    end="",
                )
                print(f"{down_command}\r", end="")

        spinner_index = (spinner_index + 1) % len(spinner_parts)
        if kill_progress:
            break


def image_worker(dry_run: bool, level: OptimizationLevel):
    global input_paths, input_lock, started_lock, started_queue, finished_lock, finished_queue

    while True:
        with input_lock:
            if len(input_paths) == 0:
                break
            image_path = input_paths.popleft()

        with started_lock:
            started_queue.append(image_path)

        command = ["sh", "main.sh", image_path, level.value]
        if not dry_run:
            subprocess.check_call(command)

        with finished_lock:
            finished_queue.append(image_path)


def main(argv: Optional[List[str]]):
    global input_paths, kill_progress

    signal.signal(signal.SIGINT, signal_handler)
    log.addHandler(logging.StreamHandler(sys.stderr))

    if argv is None:
        argv = sys.argv[1:]

    # parse arguments
    parser = argparse.ArgumentParser(prog="millipng")
    parser.add_argument("-V", "--version", action="version", version="%(prog)s 0.2.0")
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

    # prepare files to optimize
    input_paths = find_images()

    thread_count = args.jobs
    if thread_count < 0:
        log.error("Thread count can't be negative, got %s", thread_count)
        sys.exit(1)
    elif thread_count == 0:
        # get it dynamically by cpu core count
        thread_count = multiprocessing.cpu_count()
    log.debug("Using %s threads", thread_count)

    # start this deamon
    progress_work = threading.Thread(target=progress_worker, daemon=True)

    # start threads and wait for finish
    threads = [threading.Thread(target=image_worker, daemon=True, args=[args.dry_run, args.level]) for _ in range(thread_count)]
    for thread in threads:
        thread.start()
    progress_work.start()
    for thread in threads:
        thread.join()

    kill_progress = True
    progress_work.join()


if __name__ == "__main__":
    main(sys.argv[1:])
