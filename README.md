# RE:png docker meta-optimizer

[![dockerhub automated status](https://img.shields.io/docker/cloud/automated/matejkosiarcik/redopng)](https://hub.docker.com/r/matejkosiarcik/redopng/builds)
[![dockerhub build status](https://img.shields.io/docker/cloud/build/matejkosiarcik/redopng)](https://hub.docker.com/r/matejkosiarcik/redopng/builds)

<!-- toc -->

- [What](#what)
- [Usage](#usage)
  - [Help](#help)
  - [Recommendation](#recommendation)
  - [Batch processing](#batch-processing)
- [License](#license)

<!-- tocstop -->

## What

Redopng is png image meta-optimizer based in docker, inspired by these instructions <https://www.reddit.com/r/webdev/wiki/optimization#wiki_png_compression_instructions>.

A meta-optimizer? `Redopng` is not an optimizer by itself, it just calls multiple existing optimizers like `zopflipng`, `optipng`, ...

And docker? It provides consistent runtime for all other operating systems.

## Usage

Let's say you want to optimize `image.png` (in current folder), run:

```sh
docker run -v "${PWD}/image.png:/file.png" matejkosiarcik/redopng
```

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
