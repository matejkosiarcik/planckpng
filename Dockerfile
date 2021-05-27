FROM debian:10.9 AS chmod
WORKDIR /src
COPY src/main.py src/main.sh src/utils.sh ./
COPY tools/truepng-0.6.2.5.exe /usr/bin/truepng.exe
COPY tools/deflopt-2.07.exe /usr/bin/deflopt.exe
COPY tools/pngoptimizercl-2.6.2.bin /usr/bin/pngoptimizer
COPY tools/pngout-20200115.bin /usr/bin/pngout
COPY tools/defluff-0.3.2.bin /usr/bin/defluff
RUN printf '%s\n%s\n%s\n' '#!/bin/sh' 'set -euf' 'WINEDEBUG=fixme-all,err-all wine /usr/bin/truepng.exe $@' >/usr/bin/truepng && \
    printf '%s\n%s\n%s\n' '#!/bin/sh' 'set -euf' 'WINEDEBUG=fixme-all,err-all wine /usr/bin/deflopt.exe $@' >/usr/bin/deflopt && \
    chmod a+x main.py main.sh utils.sh /usr/bin/truepng /usr/bin/deflopt

# NodeJS/NPM #
FROM node:lts-slim AS node
WORKDIR /src
COPY dependencies/package.json dependencies/package-lock.json ./
RUN npm ci --unsafe-perm && \
    npm prune --production

FROM scottyhardy/docker-wine:stable-5.0.3
WORKDIR /src
COPY --from=chmod /src/main.py /src/main.sh /src/utils.sh ./
COPY --from=chmod /usr/bin/truepng.exe /usr/bin/truepng /usr/bin/deflopt.exe /usr/bin/deflopt /usr/bin/pngoptimizer /usr/bin/pngout /usr/bin/defluff /usr/bin/
COPY --from=node /src/node_modules /src/node_modules
# hadolint ignore=SC2016
RUN apt-get update --yes && \
    DEBIAN_FRONTEND=noninteractive apt-get install --yes --no-install-recommends curl optipng python3 && \
    curl -sL https://deb.nodesource.com/setup_lts.x | bash - && \
    DEBIAN_FRONTEND=noninteractive apt-get install --yes --no-install-recommends nodejs && \
    apt-get remove --purge --yes curl && \
    rm -rf /var/lib/apt/lists/* && \
    ln -s /src/main.py /usr/bin/millipng

ENTRYPOINT [ "millipng" ]
CMD []
