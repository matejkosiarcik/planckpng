#!/usr/bin/env python

from __future__ import (
    absolute_import, division, print_function, unicode_literals
)
import argparse
import sys
import threading
import time
import subprocess
import multiprocessing
import os
import re
from typing import List, Deque, Optional
import collections
import logging
import enum


# default logging config
log = logging.Logger('default', logging.INFO)

# shared state
input_paths = collections.deque()
input_lock = threading.Lock()

started_lock = threading.Lock()
started_queue = collections.deque()
finished_lock = threading.Lock()
finished_queue = collections.deque()
kill_progress = False


class OptimizationLevel(enum.Enum):
    FAST = 'fast'
    DEFAULT = 'default'
    BRUTE = 'brute'
    ULTRA_BRUTE = 'ultra-brute'

    def __str__(self):
        return self.value


class Termcode(enum.Enum):
    green = '\33[32m'
    reset = '\33[0m'

    def __str__(self):
        if sys.stdout.isatty():
            return str(self.value)
        else:
            return ''


# Find all png files to optimize
def find_images() -> Deque[str]:
    # paths = [f'/img/{x}.png' for x in range(10)]
    # return collections.deque(paths)

    if not os.path.exists('/img'):
        return collections.deque([])

    results = []
    for dirName, subdirList, fileList in os.walk('/img'):
        results += [os.path.join(dirName, x) for x in fileList if re.match(r'^.+\.png$', x)]
    results = [x for x in results if os.path.isfile(x)]
    results = sorted(results)

    log.debug('Found images: \n' + '\n'.join(f'- {x}' for x in results))

    return collections.deque(results)


# This is a dedicated thread for displaying progress
def progress_worker():
    global input_lock, input_paths, started_lock, started_queue, finished_lock, finished_queue

    while True:
        time.sleep(0.25)

        # first copy work items to our temporarary work queue to not block other threads
        temporary_work_queue = collections.deque()
        with started_lock:
            for _ in range(len(started_queue)):
                temporary_work_queue.append(started_queue.popleft())

        # process current work items
        for _ in range(len(temporary_work_queue)):
            item = temporary_work_queue.popleft()
            item = re.sub(r'^/img/', '', item)
            print(item)

        # first copy work items to our temporarary work queue to not block other threads
        temporary_work_queue = collections.deque()
        with finished_lock:
            for _ in range(len(finished_queue)):
                temporary_work_queue.append(finished_queue.popleft())

        # process current work items
        for _ in range(len(temporary_work_queue)):
            item = temporary_work_queue.popleft()
            item = re.sub(r'^/img/', '', item)
            print(f'{item} {Termcode.green}✔{Termcode.reset}')

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

        command = ['sh', 'main.sh', image_path, level.value]
        if not dry_run:
            subprocess.check_call(command)
            # time.sleep(random.uniform(0.25, 2.5))

        with finished_lock:
            finished_queue.append(image_path)


def main(argv: Optional[List[str]]):
    global input_paths, log, kill_progress

    log.addHandler(logging.StreamHandler(sys.stderr))

    if argv is None:
        argv = sys.argv[1:]

    # parse arguments
    parser = argparse.ArgumentParser(prog='millipng')
    parser.add_argument('-V', '--version', action='version', version='%(prog)s 0.2.0')
    parser.add_argument('-l', '--level', type=OptimizationLevel, choices=list(OptimizationLevel), default='default',
                        help='Optimization level')
    parser.add_argument('-n', '--dry-run', action='store_true',
                        help='Do not actually modify images')
    parser.add_argument('-j', '--jobs', type=int, default=0,
                        help='Number of parallel jobs/threads to run (default is 0 - automatically determine according to current cpu)')
    command_group = parser.add_mutually_exclusive_group() # disallow using verbose & quiet together
    command_group.add_argument('-v', '--verbose', action='store_true',
                                help='Additional logging output')
    command_group.add_argument('-q', '--quiet', action='store_true',
                                help='Suppress default logging output')
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
        log.error(f"Thread count can't be negative, got {thread_count}")
        sys.exit(1)
    elif thread_count == 0:
        # get it dynamically by cpu core count
        thread_count = multiprocessing.cpu_count()
    log.debug(f'Using {thread_count} threads')

    # start this deamon
    progress_work = threading.Thread(target=progress_worker)

    # start threads and wait for finish
    threads = [threading.Thread(target=image_worker, args=[args.dry_run, args.level]) for _ in range(thread_count)]
    for thread in threads:
        thread.start()
    progress_work.start()
    for thread in threads:
        thread.join()

    kill_progress = True
    progress_work.join()


if __name__ == "__main__":
    main(sys.argv[1:])
