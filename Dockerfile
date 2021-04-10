# BaseX 9.5 with openjdk 11 docker image
# @created 2021-03
# author="Andy Bunce"
# company="Quodatum Ltd"
# maintainer="quodatum@gmail.com"
ARG BASEX_VER
ARG JDK_VER

FROM adoptopenjdk:${JDK_VER:11-jre-hotspot} AS builder
ENV BASEX_VER=${BASEX_VER:9.5}
RUN apt-get update && apt-get install -y  unzip  && rm -rf /var/lib/apt/lists/*

ADD https://files.basex.org/releases/${BASEX_VER}/BaseX*.zip /srv
RUN cd /srv && unzip *.zip && rm *.zip

# custom options
COPY  .basex /srv/basex/

# Main image
FROM adoptopenjdk:${JDK_VER:11-jre-hotspot}
ENV BASEX_VER=${BASEX_VER:9.5}
ENV JDK_VER=${JDK_VER:11-jre-hotspot}
COPY --from=builder --chown=1000:1000 /srv/ /srv
USER 1000
ENV PATH=$PATH:/srv/basex/bin

# 1984/tcp: API
# 8984/tcp: HTTP
# 8985/tcp: HTTP stop
EXPOSE 1984 8984 8985

VOLUME ["/srv/basex/data" \
       ,"/srv/basex/webapp" \
       ,"/srv/basex/repo" \
       ,"/srv/basex/lib/custom" \
       ]
WORKDIR /srv

# Run BaseX HTTP server by default
CMD ["/srv/basex/bin/basexhttp"]

LABEL org.opencontainers.image.source="https://github.com/Quodatum/basex-docker"
LABEL org.opencontainers.image.vendor="Quodatum Ltd"
LABEL org.opencontainers.image.licenses="Apache-2.0"
LABEL link.quodatum.basex-docker.basex="${BASEX_VER}"
LABEL link.quodatum.basex-docker.jdk="${JDK_VER}"