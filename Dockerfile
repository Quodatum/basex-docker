# BaseX 9.5 with openjdk 11 docker image
# @created 2021-03
# author="Andy Bunce"
# company="Quodatum Ltd"
# maintainer="quodatum@gmail.com"

FROM adoptopenjdk:11-jre-hotspot AS builder
RUN apt-get update && apt-get install -y  unzip  && rm -rf /var/lib/apt/lists/*

ADD https://files.basex.org/releases/9.5/BaseX95.zip /srv
RUN cd /srv && unzip *.zip && rm *.zip

# custom options
COPY  .basex /srv/basex/

# Main image
FROM adoptopenjdk:11-jre-hotspot
RUN adduser -h /srv -D -u 1000 basex 
COPY --from=builder --chown=basex:basex /srv/ /srv
USER basex
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
