# Build BaseX docker image with customisation from folder basex
# You probably dont't want to change this file, instead pass in the args you want 
# via buildx.yml or similar
# @created 2021-03 
# @author="Andy Bunce"
ARG JDK_IMAGE=eclipse-temurin:17-jre
ARG BASEX_VER=https://files.basex.org/releases/11.3/BaseX113.zip

FROM $JDK_IMAGE  AS builder
ARG BASEX_VER
RUN echo 'using Basex: ' "$BASEX_VER"
RUN apt-get update && apt-get install -y  unzip wget && \
    cd /srv && wget "$BASEX_VER" && unzip *.zip && rm *.zip


# Main image
FROM $JDK_IMAGE
ARG JDK_IMAGE
ARG BASEX_VER

COPY --from=builder  /srv/ /srv

COPY  basex/.basex /srv/basex/
COPY  basex/custom/* /srv/basex/lib/custom/

# recent JDK images have user 1000=ubuntu
#RUN apt-get update && apt-get install -y adduser
#RUN addgroup --gid 1000 basex 
#RUN adduser --home /srv/basex/ --uid 1000 --gid 1000 basex 
RUN chown -R 1000:1000 /srv/basex

# Switch to 'basex'
USER 1000

ENV PATH=$PATH:/srv/basex/bin

# JVM options e.g "-Xmx2048m "
ENV BASEX_JVM=""

# ${SERVER_OPTS} eg https://docs.basex.org/main/Command-Line_Options#http_server
ENV SERVER_OPTS=""

# 1984/tcp: API
# 8080/tcp: HTTP
# 8081/tcp: HTTP stop
EXPOSE 1984 8080 8081

# no VOLUMEs defined
WORKDIR /srv

# Run BaseX HTTP server with options by default
CMD basexhttp ${SERVER_OPTS}

LABEL org.opencontainers.image.source="https://github.com/Quodatum/basex-docker"
LABEL org.opencontainers.image.vendor="Quodatum Ltd"
LABEL org.opencontainers.image.licenses="Apache-2.0"
LABEL org.opencontainers.image.description="A multi-architecture BaseX (basex.org) docker image."

LABEL com.quodatum.basex-docker.basex="${BASEX_VER}"
LABEL com.quodatum.basex-docker.jdk="${JDK_IMAGE}"
