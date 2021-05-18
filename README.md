# millipng - Very slow png optimizer

[![dockerhub automated status](https://img.shields.io/docker/cloud/automated/matejkosiarcik/millipng)](https://hub.docker.com/r/matejkosiarcik/millipng/builds)
[![dockerhub build status](https://img.shields.io/docker/cloud/build/matejkosiarcik/millipng)](https://hub.docker.com/r/matejkosiarcik/millipng/builds)

<!-- toc -->

- [Overview](#overview)
- [Usage](#usage)
  - [Help](#help)
  - [Recommendation](#recommendation)
- [License](#license)

<!-- tocstop -->

## Overview

**millipng** is a `.png` meta-optimizer.

A meta-optimizer?
`millipng` is not an optimizer by itself, it just calls multiple existing
optimizers: \[`deflopt`, `defluff`, `pngoptimizer`, `pngout`, `truepng`,
`zopflipng`\] in a specific order.
`millipng` is a lossless png optimizer (except removing exif and alpha channel
color info).

Order of execution of bundled optimizers is based on the analysis here:
<https://www.reddit.com/r/webdev/wiki/optimization#wiki_png_compression_instructions>.

`millipng` is distributed as a docker image.
This ensures consistent runtime environment with no configuration on your side
(few of the included optimizers require wine to run on non Windows OS, which is
already setup in the image).

## Usage

```sh
# optimize all pngs in current directory (recursively)
docker run -v "$PWD:/img" matejkosiarcik/millipng

# optimize single png
docker run -v "$PWD/image.png:/img" matejkosiarcik/millipng
```

### Help

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
2. use `--level ultra-rute` in _millipng_

Example:

```sh
pngquant --strip --speed 1 --skip-if-larger --quality 0-95 --force 'image.png' --output 'image.png'
docker run -v "$PWD/image.png:/img" matejkosiarcik/millipng --level ultra-brute
```

## License

The project is licensed under LGPLv3.
See [LICENSE.txt](./LICENSE.txt) for full details.
