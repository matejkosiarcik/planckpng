# RE:png docker optimizer

[![dockerhub automated status](https://img.shields.io/docker/cloud/automated/matejkosiarcik/redopng)](https://hub.docker.com/r/matejkosiarcik/redopng/builds)
[![dockerhub build status](https://img.shields.io/docker/cloud/build/matejkosiarcik/redopng)](https://hub.docker.com/r/matejkosiarcik/redopng/builds)

<!-- toc -->

## What

Redopng is png image optimizer based in docker, inspired by these instructions <https://www.reddit.com/r/webdev/wiki/optimization#wiki_png_compression_instructions>.

Why docker? It provides consistent runtime for all other OSes.

## Usage

Simply call:

```sh
docker run -v "${PWD}/image.png:/file.png" matejkosiarcik/redopng
```

\*Where "image.png" is the file you wish to optimize.
`redopng` optimizes the image in-place.

### Help

```sh
$ docker run matejkosiarcik/redopng --help
Usage: matejkosiarcik/redopng [--fast|--default|--brute]
Modes:
 --fast    Fastest, least efficient optimizations
 --default Default optimizations
 --brute   Slowest, most efficient optimizations
```

### Recommendation

To further optimize images, I recommend calling `pngquant` before `redopng`.
Beware `pngquant` is lossy.

```sh
pngquant --strip --speed 1 --skip-if-larger --quality 0-95 --force 'image.png' --output 'image.png'
# call redopng here
```

### Batch processing

You can process multiple images with find/xargs:

```sh
find . -name '*.png' -print0 | xargs -0 -n1 sh -c 'docker run -v "${PWD}/${1}:/file.png" matejkosiarcik/redopng' --
```

## License

The project is licensed under LGPLv3.
See [LICENSE.txt](./LICENSE.txt) for full details.

TL;DR: you can use the project in your open/closed source apps, but if you make
modifications to it, you should make them (as in modifications, not apps) open.
