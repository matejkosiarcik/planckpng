#!/usr/bin/env python

from __future__ import (
    absolute_import, division, print_function, unicode_literals
)
import argparse
import datetime
import sys
import threading
import time
import platform
import subprocess
import multiprocessing
import random
import os
import re
from typing import List, Deque, Optional
import collections
import logging
import enum


# default logging config
log = logging.Logger('default', logging.INFO)

# shared state
lock = threading.Lock()
images = collections.deque()


class OptimizationLevel(enum.Enum):
    FAST = 'fast'
    DEFAULT = 'default'
    BRUTE = 'brute'
    ULTRA_BRUTE = 'ultra-brute'

    def __str__(self):
        return self.value


# Find all png files to optimize
def find_images() -> Deque[str]:
    if not os.path.exists('/img'):
        return collections.deque([])

    results = []
    for dirName, subdirList, fileList in os.walk('/img'):
        results += [os.path.join(dirName, x) for x in fileList if re.match(r'^.+\.png$', x)]
    results = [x for x in results if os.path.isfile(x)]
    results = sorted(results)

    log.debug('Found images: \n' + '\n'.join(f'- {x}' for x in results))

    return collections.deque(results)


def image_worker(dry_run: bool, level: OptimizationLevel):
    global images, lock

    while True:
        with lock:
            if len(images) == 0:
                break
            image_path = images.popleft()

        log.info(f'Optimizing {image_path}')
        command = ['sh', 'main.sh', image_path, level.value]
        if not dry_run:
            log.debug('Calling: ' + ' '.join(command))
            subprocess.check_call(command)
        log.info(f'Optimized {image_path}')


def main(argv: Optional[List[str]]):
    global images, log

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
    images = find_images()

    thread_count = args.jobs
    if thread_count < 0:
        log.error(f"Thread count can't be negative, got {thread_count}")
        sys.exit(1)
    elif thread_count == 0:
        # get it dynamically by cpu core count
        thread_count = multiprocessing.cpu_count()
    log.debug(f'Using {thread_count} threads')

    # start threads and wait for finish
    threads = [threading.Thread(target=image_worker, args=[args.dry_run, args.level]) for _ in range(thread_count)]
    for thread in threads:
        thread.start()
    for thread in threads:
        thread.join()


if __name__ == "__main__":
    main(sys.argv[1:])
