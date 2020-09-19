FROM scottyhardy/docker-wine

WORKDIR /src
COPY main.sh main
COPY tools/truepng-0.6.2.5.exe truepng.exe
COPY tools/deflopt-2.07.exe deflopt.exe
COPY tools/pngoptimizercl-2.6.2 /usr/bin/pngoptimizer
COPY tools/pngout-20200115 /usr/bin/pngout
COPY tools/defluff-0.3.2 /usr/bin/defluff

USER root
RUN chmod a+x main && \
    printf '%s\n%s\n%s\n' '#!/bin/sh' 'set -euf' 'WINEDEBUG=fixme-all,err-all wine /src/truepng.exe ${@}' >/usr/bin/truepng && \
    chmod a+x /usr/bin/truepng && \
    printf '%s\n%s\n%s\n' '#!/bin/sh' 'set -euf' 'WINEDEBUG=fixme-all,err-all wine /src/deflopt.exe ${@}' >/usr/bin/deflopt && \
    chmod a+x /usr/bin/deflopt && \
    apt-get update && \
    apt-get install --yes curl optipng && \
    curl -sL https://deb.nodesource.com/setup_14.x | bash - && \
    apt-get install -y nodejs && \
    chown root -R /usr/lib/node_modules && \
    npm install --no-save zopflipng-bin

ENTRYPOINT [ "./main" ]
CMD []
