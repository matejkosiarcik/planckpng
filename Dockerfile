# checkov:skip=CKV_DOCKER_2:Disable HEALTHCHECK

FROM debian:12.0-slim AS chmod
WORKDIR /app
COPY src/main.py src/main.sh src/utils.sh ./
COPY dependencies/bin/deflopt-2.07.exe /usr/bin/deflopt.exe
COPY dependencies/bin/defluff-0.3.2.bin /usr/bin/defluff
COPY dependencies/bin/pngoptimizercl-2.6.2.bin /usr/bin/pngoptimizer
COPY dependencies/bin/pngout-20200115.bin /usr/bin/pngout
COPY dependencies/bin/truepng-0.6.2.5.exe /usr/bin/truepng.exe
RUN printf '%s\n%s\n%s\n' '#!/bin/sh' 'set -euf' 'WINEDEBUG=fixme-all,err-all wine /usr/bin/truepng.exe $@' >/usr/bin/truepng && \
    printf '%s\n%s\n%s\n' '#!/bin/sh' 'set -euf' 'WINEDEBUG=fixme-all,err-all wine /usr/bin/deflopt.exe $@' >/usr/bin/deflopt && \
    chmod a+x main.py main.sh /usr/bin/truepng /usr/bin/deflopt

FROM node:20.3.1-slim AS node
WORKDIR /app
COPY dependencies/package.json dependencies/package-lock.json ./
RUN npm ci --unsafe-perm && \
    npx node-prune && \
    npm prune --production

FROM debian:12.0-slim
WORKDIR /app
COPY --from=chmod /app/main.py /app/main.sh /app/utils.sh ./
COPY --from=chmod /usr/bin/deflopt /usr/bin/deflopt.exe /usr/bin/defluff /usr/bin/pngoptimizer /usr/bin/pngout /usr/bin/truepng /usr/bin/truepng.exe /usr/bin/
COPY --from=node /app/node_modules ./node_modules
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install --yes --no-install-recommends nodejs optipng python3 && \
    dpkg --add-architecture i386 && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install --yes --no-install-recommends libwine:i386 wine wine32 && \
    rm -rf /var/lib/apt/lists/* && \
    ln -s /app/main.py /usr/bin/planckpng && \
    useradd --create-home --no-log-init --shell /bin/sh --user-group --system planckpng

USER planckpng
ENTRYPOINT [ "planckpng" ]
CMD []
