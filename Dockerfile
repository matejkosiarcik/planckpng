FROM debian:11.2 AS chmod
WORKDIR /src
COPY src/main.py src/main.sh src/utils.sh ./
COPY tools/truepng-0.6.2.5.exe /usr/bin/truepng.exe
COPY tools/deflopt-2.07.exe /usr/bin/deflopt.exe
COPY tools/pngoptimizercl-2.6.2.bin /usr/bin/pngoptimizer
COPY tools/pngout-20200115.bin /usr/bin/pngout
COPY tools/defluff-0.3.2.bin /usr/bin/defluff
RUN printf '%s\n%s\n%s\n' '#!/bin/sh' 'set -euf' 'WINEDEBUG=fixme-all,err-all wine /usr/bin/truepng.exe $@' >/usr/bin/truepng && \
    printf '%s\n%s\n%s\n' '#!/bin/sh' 'set -euf' 'WINEDEBUG=fixme-all,err-all wine /usr/bin/deflopt.exe $@' >/usr/bin/deflopt && \
    chmod a+x main.py main.sh /usr/bin/truepng /usr/bin/deflopt

# NodeJS/NPM #
FROM node:lts-slim AS node
WORKDIR /src
COPY dependencies/package.json dependencies/package-lock.json ./
RUN npm ci --unsafe-perm && \
    npm prune --production

FROM debian:11.2-slim AS node-install
WORKDIR /src
RUN apt-get update && \
    apt-get install --yes --no-install-recommends ca-certificates curl && \
    curl -fsSL https://deb.nodesource.com/setup_lts.x -o /src/install-node.sh && \
    rm -rf /var/lib/apt/lists/*

FROM debian:11.2
WORKDIR /src
COPY --from=chmod /src/main.py /src/main.sh /src/utils.sh ./
COPY --from=chmod /usr/bin/truepng.exe /usr/bin/truepng /usr/bin/deflopt.exe /usr/bin/deflopt /usr/bin/pngoptimizer /usr/bin/pngout /usr/bin/defluff /usr/bin/
COPY --from=node-install /src/install-node.sh /src/install-node.sh
COPY --from=node /src/node_modules /src/node_modules
# hadolint ignore=SC2016
RUN bash /src/install-node.sh && \
    rm -f /src/install-node.sh && \
    dpkg --add-architecture i386 && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install --yes --no-install-recommends libwine:i386 nodejs optipng python3 wine wine32 && \
    rm -rf /var/lib/apt/lists/* && \
    ln -s /src/main.py /usr/bin/millipng

ENTRYPOINT [ "millipng" ]
CMD []
