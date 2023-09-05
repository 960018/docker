#!/usr/bin/env bash

PLATFORM=$(uname -m)

case $PLATFORM in 
    x86_64)
        ARCH=amd64
        ;;
    arm64 | aarch64)
        ARCH=arm64
        ;;
    *)
        exit
        ;;
esac

export ARCH

docker login ghcr.io -u "$CR_USER" --password "$CR_PAT"

docker buildx build --tag ghcr.io/960018/scratch:latest        --push --compress --no-cache --sbom=false --provenance=false -f Dockerfile.scratch .                                 || exit
docker buildx build --tag ghcr.io/960018/nginx:$ARCH           --push --compress --no-cache --sbom=false --provenance=false -f Dockerfile.debian.nginx .                            || exit
docker buildx build --tag ghcr.io/960018/keydb:$ARCH           --push --compress --no-cache --sbom=false --provenance=false -f Dockerfile.debian.keydb .                            || exit
docker buildx build --tag ghcr.io/960018/bun:$ARCH             --push --compress --no-cache --sbom=false --provenance=false -f Dockerfile.debian.bun .                              || exit

docker buildx build --tag ghcr.io/960018/node:20-$ARCH         --push --compress --no-cache --sbom=false --provenance=false -f Dockerfile.debian.node --build-arg VERSION=20.5.1 .  || exit
docker buildx build --tag ghcr.io/960018/node:18-$ARCH         --push --compress --no-cache --sbom=false --provenance=false -f Dockerfile.debian.node --build-arg VERSION=18.17.1 . || exit
docker buildx build --tag ghcr.io/960018/node:18-$ARCH-ip      --push --compress --no-cache --sbom=false --provenance=false -f Dockerfile.debian.ip --build-arg OS=$ARCH .          || exit
docker buildx build --tag ghcr.io/960018/node:18-$ARCH-echo    --push --compress --no-cache --sbom=false --provenance=false -f Dockerfile.debian.echo --build-arg OS=$ARCH .        || exit

docker buildx build --tag ghcr.io/960018/curl:$ARCH            --push --compress --no-cache --sbom=false --provenance=false -f Dockerfile.debian.curl .                             || exit
docker buildx build --tag ghcr.io/960018/php-fpm:$ARCH         --push --compress --no-cache --sbom=false --provenance=false -f Dockerfile.debian.php --build-arg OS=$ARCH .         || exit
docker buildx build --tag ghcr.io/960018/php-fpm:testing-$ARCH --push --compress --no-cache --sbom=false --provenance=false -f Dockerfile.debian.php.testing --build-arg OS=$ARCH . || exit
