# BaseX Dockerfile

An experimental alternative BaseX docker image.  
Published at https://hub.docker.com/r/quodatum/basexhttp
See also  https://hub.docker.com/r/basex/basexhttp
## Features

- adds a lib/custom volume for extension jars
- currently using Java `openjdk11-jre-headless`
- multi-arch-build, currently supported platforms  `linux/arm64/v8`,`linux/amd64`
- runs as user 1000 rather than 1984 (see https://docs.basex.org/wiki/Docker#Non-privileged_User)
- --significantly smaller image--

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
docker buildx build  \
    --platform linux/arm/v7,linux/arm64,linux/amd64 \
    --tag quodatum/basexhttp:buildx-latest --push .
```
## image
 openjdk11-jre-headless is based on ubuntu 20.04
## Notes
 
Building on Ubuntu 20.04 running on a Window 10 machine with WSL2 and docker desktop.
See https://ubuntu.com/tutorials/ubuntu-on-windows failed:
 
```
#33 10.08 error: failed to copy: failed to do request: Put https://registry-1.docker.io/v2/quodatum/basexhttp/blobs/uploads/ee5e2f6a-0b20-429a-9c88-92d3d1a6eca9?_state=m87KDmxHjVbjdQKLraqWWG7N52cRpXZICKIpfBMhaAp7Ik5hbWUiOiJxdW9kYXR1bS9iYXNleGh0dHAiLCJVVUlEIjoiZWU1ZTJmNmEtMGIyMC00MjlhLTljODgtOTJkM2QxYTZlY2E5IiwiT2Zmc2V0IjowLCJTdGFydGVkQXQiOiIyMDIxLTA0LTA1VDIwOjI5OjMwLjc4Nzc2OTg4M1oifQ%3D%3D&digest=sha256%3A2b310eb6279419eece82e847effefb67be66a3b8e631fda5532880177728460e: write tcp 172.17.0.2:58952->52.5.11.128:443: use of closed network connection
#33 10.08 retrying in 1s
``
