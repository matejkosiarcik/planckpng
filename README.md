# millipng - Very slow png optimizer

[![dockerhub automated status](https://img.shields.io/docker/cloud/automated/matejkosiarcik/millipng)](https://hub.docker.com/r/matejkosiarcik/millipng/builds)
[![dockerhub build status](https://img.shields.io/docker/cloud/build/matejkosiarcik/millipng)](https://hub.docker.com/r/matejkosiarcik/millipng/builds)

<!-- toc -->

- [What](#what)
- [Usage](#usage)
  - [Help](#help)
  - [Recommendation](#recommendation)
  - [Batch processing](#batch-processing)
- [License](#license)

<!-- tocstop -->

## What

`millipng` is png image meta-optimizer based in docker, inspired by these
instructions
<https://www.reddit.com/r/webdev/wiki/optimization#wiki_png_compression_instructions>.

A meta-optimizer? `millipng` is not an optimizer by itself,
it just calls multiple existing optimizers like
`zopflipng`, `optipng`, `truepng`, `deflopt`, `pngout` ...
Need I go on?

Why docker?
It provides consistent runtime for all other operating systems.
Some tools require windows/wine, so you don't need to bother with it as well as other dependencies.

## Usage

Let's say you want to optimize `image.png` (in current folder), run:

```sh
docker run -v "${PWD}/image.png:/file.png" matejkosiarcik/millipng
```

`millipng` optimizes the image in-place.

### Help

```sh
$ docker run matejkosiarcik/millipng --help
Usage: matejkosiarcik/millipng [--fast|--default|--brute]
Modes:
 --fast    Fastest, least efficient optimizations
 --default Default optimizations
 --brute   Slowest, most efficient optimizations
```

### Recommendation

To further optimize images, I recommend calling `pngquant` before `millipng`.
Beware `pngquant` is lossy.

```sh
pngquant --strip --speed 1 --skip-if-larger --quality 0-95 --force 'image.png' --output 'image.png'
# call millipng here
```

### Batch processing

You can process multiple images with find/xargs:

```sh
find . -name '*.png' -print0 | xargs -0 -n1 sh -c 'docker run -v "${PWD}/${1}:/file.png" matejkosiarcik/millipng' --
```

## License

The project is licensed under LGPLv3.
See [LICENSE.txt](./LICENSE.txt) for full details.

TL;DR: you can use the project in your open/closed source apps, but if you make
modifications to it, you should make them (as in modifications, not apps) open.
