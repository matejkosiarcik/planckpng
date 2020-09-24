# RE:png docker optimizer

> Based mostly on these instructions <https://www.reddit.com/r/webdev/wiki/optimization#wiki_png_compression_instructions>

## Usage

Simply call:

```sh
docker run -v "${PWD}/image.png:/file.png" matejkosiarcik/redopng
```

\*Where "image.png" is the file you wish to optimize.
`redopng` optimizes the image in-place.

### Recommended

I recommend calling `pngquant` before `redopng`:

```sh
pngquant --strip --speed 1 --skip-if-larger --quality 0-95 --force 'image.png' --output 'image.png'
# docker run ... # call redopng normally
```

Beware `pngquant` is lossy.

## License

The project is licensed under LGPLv3.
See [LICENSE.txt](./LICENSE.txt) for full details.

TL;DR: you can use the project in your open/closed source apps, but if you make
modifications to it, you should make them (as in modifications, not apps) open.
