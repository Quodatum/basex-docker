#
# BaseX on alpine with openjdk 11 docker image
# @author Andy Bunce
FROM alpine:latest AS builder
RUN apk --no-cache add zip
ADD https://files.basex.org/releases/9.5/BaseX95.zip /srv
RUN cd /srv && unzip *.zip && rm *.zip

# custom options
COPY  .basex /srv/basex/

# Main image
FROM alpine:latest
LABEL author="Andy Bunce"
LABEL company="Quodatum Ltd"
LABEL maintainer="quodatum@gmail.com"


ENV JAVA_HOME="/usr/lib/jvm/default-jvm/"
RUN apk add --no-cache bash openjdk11-jre-headless
# Has to be set explictly to find binaries 
ENV PATH=$PATH:${JAVA_HOME}/bin

RUN adduser -h /srv -D -u 1000 basex 
COPY --from=builder --chown=basex:basex /srv/ /srv

USER basex
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
