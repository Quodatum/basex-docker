# BaseX Dockerfile

An experimental alternative BaseX docker image.  
Published at https://hub.docker.com/r/quodatum/basexhttp
See also  https://hub.docker.com/r/basex/basexhttp
## Features

- significantly smaller image
- adds a lib/custom volume for extension jars
- currently using Java `openjdk11-jre-headless`
- multi-arch-build, currently supported platforms  `linux/arm64/v8`,`linux/amd64`
- runs as user 1000 rather than 1984 (see https://docs.basex.org/wiki/Docker#Non-privileged_User)
```
docker run -d \
    --name basexhttpq \
    --publish 1984:1984 \
    --publish 8984:8984 \
    --volume "$HOME/basex/data":/srv/basex/data \
    --volume "$HOME/basex/repo":/srv/basex/repo \
    --volume "$HOME/basex/webapp":/srv/basex/webapp \
    --volume "$HOME/basex/custom":/srv/basex/lib/custom \
    quodatum/basexhttp:latest
```
## Build

You will need to enable experimental Docker CLI features. See

- https://www.docker.com/blog/multi-arch-build-and-images-the-simple-way/
- https://dev.to/arturklauser/building-multi-architecture-docker-images-with-buildx-1mii

then...

```
docker buildx build --push \
    --platform linux/arm64/v8,linux/amd64 \
    --tag quodatum/basexhttp:buildx-latest .
```
## Notes
Built in Ubuntu 20.04 running on a Window 10 machine with WSL2 and docker desktop.
See https://ubuntu.com/tutorials/ubuntu-on-windows

Currently `linux/arm/v7` fails to build due to missing `openjdk11-jre-headless`?