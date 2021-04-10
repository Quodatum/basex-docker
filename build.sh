#!/bin/bash
# @see https://www.docker.com/blog/multi-arch-build-and-images-the-simple-way/
# exit when any command fails
set -e

# keep track of the last executed command
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
# echo an error message before exiting
trap 'echo "\"${last_command}\" command filed with exit code $?."' EXIT

image=quodatum/basexhttp

make2(){
# $1 platform, $2 tag eg `make2 linux/amd64 amd64`
 echo "###### docker buildx build --platform $1 --tag $image:manifest-$2 ."
 docker buildx build --platform "$1" --tag "$image:manifest-$2" --push .
}

manifest(){
 docker manifest create  "$image"  "$image:manifest-amd64"  "$image:manifest-armv7"  "$image:manifest-arm64"
 docker manifest push --purge "$image" 
}

echo hello pushing "$image" to docker hub
make2 linux/arm/v7 armv7
make2 linux/arm64 arm64
make2 linux/amd64 amd64
manifest

