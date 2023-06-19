# PlanckPNG

> Ultra-brute PNG meta-optimizer

[![dockerhub version](https://img.shields.io/docker/v/matejkosiarcik/planckpng?label=dockerhub&sort=semver)](https://hub.docker.com/r/matejkosiarcik/planckpng/tags?page=1&ordering=last_updated)
[![github version](https://img.shields.io/github/v/release/matejkosiarcik/planckpng?sort=semver)](https://github.com/matejkosiarcik/planckpng/releases)

<!-- toc -->

- [Overview](#overview)
  - [Features](#features)
- [Usage](#usage)
  - [Linux & macOS](#linux--macos)
  - [Windows](#windows)
  - [Recommendations](#recommendations)
- [Help](#help)
- [License](#license)

<!-- tocstop -->

## Overview

**PlanckPNG** is a `.png` meta-optimizer.

A meta-optimizer?
_PlanckPNG_ is not an optimizer by itself, it just calls multiple existing
optimizers (_Deflopt_, _defluff_, _OptiPNG_, _PngOptimizer_, _PNGOUT_,
_TruePNG_, _ZopfliPNG_) in a specific order described by (not mine) analysis
here:
[reddit.com/r/webdev/wiki](https://www.reddit.com/r/webdev/wiki/optimization#wiki_png_compression_instructions).

_PlanckPNG_ is a lossless PNG optimizer (except removing exif and alpha channel
color info).

_PlanckPNG_ is distributed as a docker image.
This ensures consistent runtime environment with no configuration on your side
(few of the included optimizers require wine to run on non Windows OS, which is
already setup in the image).

### Features

- ✨ Best in class optimization
- 📂 Optimize single file or whole directory

## Usage

![PlanckPNG demo](./doc/demo.gif)

### Linux & macOS

```sh
# optimize all pngs in current directory (recursively)
docker run -v "$PWD:/img" matejkosiarcik/planckpng

# optimize a single png
docker run -v "$PWD/image.png:/img" matejkosiarcik/planckpng
```

### Windows

```bat
# optimize all PNGs in current directory (recursively)
docker run -v "%cd%:/img" matejkosiarcik/planckpng

# optimize a single PNG
docker run -v "%cd%/image.png:/img" matejkosiarcik/planckpng
```

### Recommendations

For maximum optimization, I recommend

1. call _pngquant_ before _planckpng_ (beware _pngquant_ is lossy)
2. use `--level ultra-brute` in _planckpng_ (beware this takes a **really long time** for any sizible PNG)

Example:

```sh
pngquant --strip --speed 1 --skip-if-larger --quality 0-95 --force 'image.png' --output 'image.png'
docker run -v "$PWD/image.png:/img" matejkosiarcik/planckpng --level ultra-brute
```

## Help

```sh
$ docker run matejkosiarcik/planckpng --help
usage: planckpng [-h] [-V] [-l {fast,default,brute,ultra-brute}] [-n] [-j JOBS]
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

## License

The project is licensed under LGPLv3.
See [LICENSE.txt](./LICENSE.txt) for full details.
