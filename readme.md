# BaseX Dockerfile
[![multi-arch docker buildx](https://github.com/Quodatum/basex-docker/actions/workflows/buildx.yml/badge.svg)](https://github.com/Quodatum/basex-docker/actions/workflows/buildx.yml)

Experiments with an alternative [BaseX](https://basex.org)  multi-architecture docker image. 
## Features
- Supported platforms `linux/amd64`, `linux/arm64`, `linux/arm/v7`
- Adds a lib/custom volume for extension jars
- Currently using Java `openjdk11-jre-headless`
- Runs as user 1000 rather than 1984 (see https://docs.basex.org/wiki/Docker#Non-privileged_User)

- `InaccessibleObjectException` [remediation](https://www.mail-archive.com/basex-talk%40mailman.uni-konstanz.de/msg13498.html) via JVM options
 
## Pull
This image from https://hub.docker.com/r/quodatum/basexhttp
```
docker pull quodatum/basexhttp:latest
```

This image from github ghcr.io
```
docker pull ghcr.io/quodatum/basexhttp:latest
```

The official BaseX image on docker hub
```
docker pull basex/basexhttp:latest
```

## Supported JVM versions
* adoptopenjdk:11-jre-hotspot
### to be tested
* adoptopenjdk:16-jre-hotspot
* adoptopenjdk:15-jre-hotspot
* adoptopenjdk:12-jre-hotspot 
* adoptopenjdk:8-jre-hotspot 
* 
## Dockerfile notes

### Java image
Java `openjdk11-jre-headless` is based on ubuntu 20.04
### JVM options
#### inaccessibleobjectexception

* --add-opens java.base/java.net=ALL-UNNAMED 
* --add-opens java.base/jdk.internal.loader=ALL-UNNAMED
* 
[see](https://stackoverflow.com/questions/41265266/how-to-solve-inaccessibleobjectexception-unable-to-make-member-accessible-m)

## Run examples
```
# run using repo
 docker run  -p 28984:8984 -v `pwd`/repo:/srv/basex/repo quodatum/basexhttp:latest

# webapp
docker run  -p 28984:8984 \
            -v `pwd`/webapp:/srv/basex/webapp \
            -v `pwd`/repo:/srv/basex/repo \
            quodatum/basexhttp:latest
```
## Build

In my experience pushing a locally built multi-arch image often failed. See below for details. 
[Github actions](https://docs.github.com/en/actions) worked.
### Github actions buildx 

* [buildx workflow](https://github.com/Quodatum/basex-docker/actions/workflows/buildx.yml)
* [buildx code](https://github.com/Quodatum/basex-docker/blob/main/.github/workflows/buildx.yml)

### Local buildx

You will need to enable experimental Docker CLI features. See

- https://www.docker.com/blog/multi-arch-build-and-images-the-simple-way/
- https://dev.to/arturklauser/building-multi-architecture-docker-images-with-buildx-1mii

then...

```
docker buildx build  \
    --platform linux/arm/v7,linux/arm64,linux/amd64 \
    --tag quodatum/basexhttp:buildx-latest --push .
```

In my experience this failed..
 
Building on Ubuntu 20.04 running on a Window 10 machine with
 [WSL2 and docker desktop](https://ubuntu.com/tutorials/ubuntu-on-windows failed)
 
```
#33 10.08 error: failed to copy: failed to do request: Put https://registry-1.docker.io/v2/quodatum/basexhttp/blobs/uploads/ee5e2f6a-0b20-429a-9c88-92d3d1a6eca9?_state=m87KDmxHjVbjdQKLraqWWG7N52cRpXZICKIpfBMhaAp7Ik5hbWUiOiJxdW9kYXR1bS9iYXNleGh0dHAiLCJVVUlEIjoiZWU1ZTJmNmEtMGIyMC00MjlhLTljODgtOTJkM2QxYTZlY2E5IiwiT2Zmc2V0IjowLCJTdGFydGVkQXQiOiIyMDIxLTA0LTA1VDIwOjI5OjMwLjc4Nzc2OTg4M1oifQ%3D%3D&digest=sha256%3A2b310eb6279419eece82e847effefb67be66a3b8e631fda5532880177728460e: write tcp 172.17.0.2:58952->52.5.11.128:443: use of closed network connection
#33 10.08 retrying in 1s
```

The script `build.sh` has more success by pushing each arch seperately.