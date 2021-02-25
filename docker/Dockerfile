FROM scottyhardy/docker-wine:stable-5.0.2

WORKDIR /src

# copy tools
COPY src/main.sh main
COPY tools/truepng-0.6.2.5.exe truepng.exe
COPY tools/deflopt-2.07.exe deflopt.exe
COPY tools/pngoptimizercl-2.6.2.bin /usr/bin/pngoptimizer
COPY tools/pngout-20200115.bin /usr/bin/pngout
COPY tools/defluff-0.3.2.bin /usr/bin/defluff
COPY package.json .
COPY package-lock.json .

# hadolint ignore=SC2016,DL4006
RUN chmod a+x main && \
    printf '%s\n%s\n%s\n' '#!/bin/sh' 'set -euf' 'WINEDEBUG=fixme-all,err-all wine /src/truepng.exe ${@}' >/usr/bin/truepng && \
    chmod a+x /usr/bin/truepng && \
    printf '%s\n%s\n%s\n' '#!/bin/sh' 'set -euf' 'WINEDEBUG=fixme-all,err-all wine /src/deflopt.exe ${@}' >/usr/bin/deflopt && \
    chmod a+x /usr/bin/deflopt && \
    apt-get update && \
    apt-get install --yes --no-install-recommends curl optipng && \
    curl -sL https://deb.nodesource.com/setup_14.x | bash - && \
    apt-get install --yes --no-install-recommends nodejs && \
    rm -rf /var/lib/apt/lists/* && \
    npm install

ENTRYPOINT [ "./main" ]
CMD []
