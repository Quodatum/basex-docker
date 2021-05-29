# BaseX 9.5 with openjdk 11 docker image
# @created 2021-03
# author="Andy Bunce"
ARG JDK_IMAGE=adoptopenjdk:11-jre-hotspot
ARG BASEX_VER=https://files.basex.org/releases/9.5/BaseX95.zip

FROM $JDK_IMAGE  AS builder
ARG BASEX_VER
RUN echo 'using Basex: ' "$BASEX_VER"
RUN apt-get update && apt-get install -y  unzip wget && \
    cd /srv && wget "$BASEX_VER" && unzip *.zip && rm *.zip
COPY  .basex /srv/basex/

# Main image
FROM $JDK_IMAGE
ARG JDK_IMAGE
ARG BASEX_VER
COPY --from=builder --chown=1000:1000 /srv/ /srv

USER 1000
ENV PATH=$PATH:/srv/basex/bin
# JVM options e.g "-Xmx2048m "
ENV BASEX_JVM="--add-opens java.base/java.net=ALL-UNNAMED --add-opens java.base/jdk.internal.loader=ALL-UNNAMED"

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
LABEL link.quodatum.basex-docker.jdk="${JDK_IMAGE}"