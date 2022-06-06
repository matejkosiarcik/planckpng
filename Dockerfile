FROM debian:11.3-slim AS chmod
WORKDIR /src
COPY src/main.py src/main.sh src/utils.sh ./
COPY tools/deflopt-2.07.exe /usr/bin/deflopt.exe
COPY tools/defluff-0.3.2.bin /usr/bin/defluff
COPY tools/pngoptimizercl-2.6.2.bin /usr/bin/pngoptimizer
COPY tools/pngout-20200115.bin /usr/bin/pngout
COPY tools/truepng-0.6.2.5.exe /usr/bin/truepng.exe
RUN printf '%s\n%s\n%s\n' '#!/bin/sh' 'set -euf' 'WINEDEBUG=fixme-all,err-all wine /usr/bin/truepng.exe $@' >/usr/bin/truepng && \
    printf '%s\n%s\n%s\n' '#!/bin/sh' 'set -euf' 'WINEDEBUG=fixme-all,err-all wine /usr/bin/deflopt.exe $@' >/usr/bin/deflopt && \
    chmod a+x main.py main.sh /usr/bin/truepng /usr/bin/deflopt

FROM node:18.3.0-slim AS node
WORKDIR /src
COPY dependencies/package.json dependencies/package-lock.json ./
RUN npm ci --unsafe-perm && \
    npm prune --production

FROM debian:11.3-slim
WORKDIR /src
COPY --from=chmod /src/main.py /src/main.sh /src/utils.sh ./
COPY --from=chmod /usr/bin/deflopt /usr/bin/deflopt.exe /usr/bin/defluff /usr/bin/pngoptimizer /usr/bin/pngout /usr/bin/truepng /usr/bin/truepng.exe /usr/bin/
COPY --from=node /src/node_modules /src/node_modules
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install --yes --no-install-recommends nodejs optipng python3 && \
    dpkg --add-architecture i386 && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install --yes --no-install-recommends libwine:i386 wine wine32 && \
    rm -rf /var/lib/apt/lists/* && \
    ln -s /src/main.py /usr/bin/millipng

ENTRYPOINT [ "millipng" ]
CMD []
