#!/bin/bash
image=quodatum/basexhttp

manifest(){
 docker manifest create  "$image" --amend "$image:manifest-amd64" --amend "$image:manifest-armv7" --amend "$image:manifest-arm64v8" 
}
make2(){
# $1 platform, $2 tag eg `make2 linux/amd64 amd64`
 echo "###### docker buildx build --platform $1 --tag $image:manifest-$2 ."
 docker buildx build --platform "$1" --tag "$image:manifest-$2" --push .
}

#docker manifest push your-username/multiarch-example:manifest-latest
echo hello pushing "$image" to docker hub
make2 linux/arm/v7 armv7
make2 linux/arm64 arm64
make2 linux/amd64 amd64
manifest

