#!/usr/bin/env bash

PLATFORM=$(uname -m)

case $PLATFORM in 
    x86_64)
        ARCH=amd64
        RELAY=x86-64
        ;;
    arm64)
        ARCH=macos
        RELAY=aarch64
        ;;
    aarch64)
        ARCH=arm64
        RELAY=aarch64
        ;;
    *)
        exit
        ;;
esac

export ARCH

docker login ghcr.io -u "$CR_USER" --password "$CR_PAT"

docker buildx build --tag ghcr.io/960018/curl:$ARCH --push --compress --no-cache --sbom=false --provenance=false -f Dockerfile.debian.curl . || exit
docker buildx build --tag ghcr.io/960018/nginx:$ARCH --push --compress --no-cache --sbom=false --provenance=false -f Dockerfile.debian.nginx . || exit
docker buildx build --tag ghcr.io/960018/keydb:$ARCH --push --compress --no-cache --sbom=false --provenance=false -f Dockerfile.debian.keydb --build-arg VERSION=latest . || exit
docker buildx build --tag ghcr.io/960018/node:$ARCH --push --compress --no-cache --sbom=false --provenance=false -f Dockerfile.debian.node . || exit
docker buildx build --tag ghcr.io/960018/php-fpm:$ARCH --push --compress --no-cache --sbom=false --provenance=false -f Dockerfile.debian.php --build-arg RELAY=$RELAY --build-arg OS=$ARCH . || exit
docker buildx build --tag ghcr.io/960018/php-fpm:testing-$ARCH --push --compress --no-cache --sbom=false --provenance=false -f Dockerfile.debian.php.testing --build-arg OS=$ARCH . || exit
