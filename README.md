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

**millipng** is a `.png` meta-optimizer.

A meta-optimizer?
`millipng` is not an optimizer by itself, it just calls multiple existing optimizers: \[`deflopt`, `defluff`, `pngoptimizer`, `pngout`, `truepng`, `zopflipng`\] in a specific order (below).
`millipng` is a lossless optimizer (beside exif and alpha channel).

Order of execution of these tools is based on an analysis here: <https://www.reddit.com/r/webdev/wiki/optimization#wiki_png_compression_instructions>.

`millipng` is distributed as a docker image.
This ensures consistent runtime environment with no configuration on your side (few of the tools used are only available as windows executables (`.exe`) and so require eg. wine under macOS/Linux, which is conveniently already setup in the image).

## Usage

Let's say you want to optimize `image.png` (in current working directory), run:

```sh
docker run -v "${PWD}/image.png:/file.png" matejkosiarcik/millipng --brute
```

`millipng` optimizes the image in-place.
I recommend `--brute` option for maximum optimizations.
Be ware though, this takes a long time.
For quicker optimizations see all the options below.

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

To achieve even better optimizion, I recommend calling `pngquant` (or your favorite quantizer instead) before `millipng`.
Beware `pngquant` is lossy.
Example:

```sh
pngquant --strip --speed 1 --skip-if-larger --quality 0-95 --force 'image.png' --output 'image.png'
docker run -v "${PWD}/image.png:/file.png" matejkosiarcik/millipng --brute
```

### Batch processing

`millipng` currently only accepts 1 file as an input/output.
You can process multiple images using find/xargs.
Example:

```sh
find . -name '*.png' -print0 | xargs -0 -n1 sh -c 'docker run -v "${PWD}/${1}:/file.png" matejkosiarcik/millipng' --
```

## License

The project is licensed under LGPLv3.
See [LICENSE.txt](./LICENSE.txt) for full details.
