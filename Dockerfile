FROM scottyhardy/docker-wine:stable-5.0.3

WORKDIR /src

COPY dependencies/package.json dependencies/package-lock.json ./
COPY --chmod=777 src/main.py src/main.sh src/utils.sh ./
COPY tools/truepng-0.6.2.5.exe /usr/bin/truepng.exe
COPY tools/deflopt-2.07.exe /usr/bin/deflopt.exe
COPY tools/pngoptimizercl-2.6.2.bin /usr/bin/pngoptimizer
COPY tools/pngout-20200115.bin /usr/bin/pngout
COPY tools/defluff-0.3.2.bin /usr/bin/defluff

# hadolint ignore=SC2016
RUN printf '%s\n%s\n%s\n' '#!/bin/sh' 'set -euf' 'python3 /src/main.py $@' >/usr/bin/millipng && \
    printf '%s\n%s\n%s\n' '#!/bin/sh' 'set -euf' 'WINEDEBUG=fixme-all,err-all wine /usr/bin/truepng.exe $@' >/usr/bin/truepng && \
    printf '%s\n%s\n%s\n' '#!/bin/sh' 'set -euf' 'WINEDEBUG=fixme-all,err-all wine /usr/bin/deflopt.exe $@' >/usr/bin/deflopt && \
    chmod a+x /usr/bin/millipng /usr/bin/truepng /usr/bin/deflopt && \
    apt-get update --yes && \
    DEBIAN_FRONTEND=noninteractive apt-get install --yes --no-install-recommends curl bc optipng python3 && \
    curl -sL https://deb.nodesource.com/setup_lts.x | bash - && \
    DEBIAN_FRONTEND=noninteractive apt-get install --yes --no-install-recommends nodejs && \
    rm -rf /var/lib/apt/lists/* && \
    npm ci && \
    npm prune --production

ENTRYPOINT [ "millipng" ]
CMD []
