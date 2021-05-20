# millipng - Very slow png optimizer

[![dockerhub automated status](https://img.shields.io/docker/cloud/automated/matejkosiarcik/millipng)](https://hub.docker.com/r/matejkosiarcik/millipng/builds)
[![dockerhub build status](https://img.shields.io/docker/cloud/build/matejkosiarcik/millipng)](https://hub.docker.com/r/matejkosiarcik/millipng/builds)

<!-- toc -->

- [Overview](#overview)
- [Usage](#usage)
  - [Recommendation](#recommendation)
- [License](#license)

<!-- tocstop -->

## Overview

**millipng** is a `.png` meta-optimizer.

A meta-optimizer?
_millipng_ is not an optimizer by itself, it just calls multiple existing
optimizers (_deflopt_, _defluff_, _optipng_, _pngoptimizer_, _pngout_,
_truepng_, _zopflipng_) in a specific order described by (not mine) analysis
here:
[reddit.com/r/webdev/wiki](https://www.reddit.com/r/webdev/wiki/optimization#wiki_png_compression_instructions).

_millipng_ is a lossless png optimizer (except removing exif and alpha channel
color info).

_millipng_ is distributed as a docker image.
This ensures consistent runtime environment with no configuration on your side
(few of the included optimizers require wine to run on non Windows OS, which is
already setup in the image).

## Usage

![millipng demo](./doc/demo.gif)

```sh
# optimize all pngs in current directory (recursively)
docker run -v "$PWD:/img" matejkosiarcik/millipng

# optimize single png
docker run -v "$PWD/image.png:/img" matejkosiarcik/millipng
```

When in doubt, get help:

```sh
$ docker run matejkosiarcik/millipng --help
usage: millipng [-h] [-V] [-l {fast,default,brute,ultra-brute}] [-n] [-j JOBS]
                [-v | -q]

optional arguments:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  -l {fast,default,brute,ultra-brute}, --level {fast,default,brute,ultra-brute}
                        Optimization level
  -n, --dry-run         Do not actually modify images
  -j JOBS, --jobs JOBS  Number of parallel jobs/threads to run (default is 0 -
                        automatically determine according to current cpu)
  -v, --verbose         Additional logging output
  -q, --quiet           Suppress default logging output
```

### Recommendation

For maximum results, I recommend

1. call _pngquant_ before _millipng_ (beware _pngquant_ is lossy)
2. use `--level ultra-rute` in _millipng_ (beware this takes a **really long time** for any sizible png)

Example:

```sh
pngquant --strip --speed 1 --skip-if-larger --quality 0-95 --force 'image.png' --output 'image.png'
docker run -v "$PWD/image.png:/img" matejkosiarcik/millipng --level ultra-brute
```

## License

The project is licensed under LGPLv3.
See [LICENSE.txt](./LICENSE.txt) for full details.
