# BaseX Dockerfile
[![multi-arch docker buildx](https://github.com/Quodatum/basex-docker/actions/workflows/buildx.yml/badge.svg)](https://github.com/Quodatum/basex-docker/actions/workflows/buildx.yml)

Experiments with an alternative [BaseX](https://basex.org)  multi-architecture docker image. 
The github action script `buildx.yml` publishes images to docker hub and github container repositories.
## Features


- Supported platforms `linux/amd64`, `linux/arm64`, `linux/arm/v7`
- Adds `saxon-he-10.8.jar` from [Saxonica](https://www.saxonica.com/products/products.xml) to `lib/custom` for XSLT 3.0 support
- Runs as user 1000 rather than 1984 (see https://docs.basex.org/wiki/Docker#Non-privileged_User)
- `InaccessibleObjectException` [remediation](https://www.mail-archive.com/basex-talk%40mailman.uni-konstanz.de/msg13498.html) via JVM options
 
## Pull
This image from [docker hub](https://hub.docker.com/r/quodatum/basexhttp)
```
docker pull quodatum/basexhttp:latest
```

This image from [github ghcr.io](https://github.com/Quodatum/basex-docker/pkgs/container/basexhttp)
```
docker pull ghcr.io/quodatum/basexhttp:latest
```

The official BaseX image on docker hub
```
docker pull basex/basexhttp:latest
```
## Run examples
```
# basic run: access to dba and chat, but no data persistance
 docker run  -p 8984:8984  quodatum/basexhttp:latest

# persist data and settings to a local folder
mkdir data 
chown -R 1000:1000 data

docker run  -p 8984:8984 \
            -v `pwd`/data:/srv/basex/data \
            -d quodatum/basexhttp:latest 
```
# webapp
```
docker run  -p 28984:8984 \
            -v `pwd`/webapp:/srv/basex/webapp \
            -v `pwd`/repo:/srv/basex/repo \
            quodatum/basexhttp:latest
```
## Supported JVM versions
Tested largely with `adoptopenjdk:11-jre-hotspot`. This is based on ubuntu 20.04. It is used because it is available for all the supported platforms.
* 
## Dockerfile notes

### JVM options
#### inaccessibleobjectexception

* --add-opens java.base/java.net=ALL-UNNAMED 
* --add-opens java.base/jdk.internal.loader=ALL-UNNAMED
 
[see](https://stackoverflow.com/questions/41265266/how-to-solve-inaccessibleobjectexception-unable-to-make-member-accessible-m)



## Docker-compose

## Components
* [BaseX](https://basex.org/about/open-source/) 3-clause BSD License

* [Saxon-HE](https://sourceforge.net/projects/saxon/) Mozilla Public License 2.0 
