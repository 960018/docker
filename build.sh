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

docker buildx build --tag ghcr.io/960018/scratch:latest             --push --compress --no-cache --sbom=false --provenance=false -f scratch.dockerfile .                               || exit
docker buildx build --tag ghcr.io/960018/nginx:$ARCH                --push --compress --no-cache --sbom=false --provenance=false -f nginx.dockerfile .                                 || exit
docker buildx build --tag ghcr.io/960018/keydb:$ARCH                --push --compress --no-cache --sbom=false --provenance=false -f keydb.dockerfile .                                 || exit
docker buildx build --tag ghcr.io/960018/bun:$ARCH                  --push --compress --no-cache --sbom=false --provenance=false -f bun.dockerfile .                                   || exit

docker buildx build --tag ghcr.io/960018/node:20-$ARCH              --push --compress --no-cache --sbom=false --provenance=false -f node.dockerfile --build-arg VERSION=20.5.1 .       || exit
docker buildx build --tag ghcr.io/960018/node:18-$ARCH              --push --compress --no-cache --sbom=false --provenance=false -f node.dockerfile --build-arg VERSION=18.17.1 .      || exit
docker buildx build --tag ghcr.io/960018/node:18-$ARCH-ip           --push --compress --no-cache --sbom=false --provenance=false -f node.ip.dockerfile --build-arg OS=$ARCH .          || exit
docker buildx build --tag ghcr.io/960018/node:18-$ARCH-echo         --push --compress --no-cache --sbom=false --provenance=false -f node.echo.dockerfile --build-arg OS=$ARCH .        || exit

docker buildx build --tag ghcr.io/960018/curl:$ARCH                 --push --compress --no-cache --sbom=false --provenance=false -f curl.dockerfile .                                  || exit
docker buildx build --tag ghcr.io/960018/php-fpm:$ARCH              --push --compress --no-cache --sbom=false --provenance=false -f php.dockerfile --build-arg OS=$ARCH .              || exit
docker buildx build --tag ghcr.io/960018/php-fpm:testing-$ARCH      --push --compress --no-cache --sbom=false --provenance=false -f php.testing.dockerfile --build-arg OS=$ARCH .      || exit

docker buildx build --tag ghcr.io/960018/php-fpm:$ARCH-sock         --push --compress --no-cache --sbom=false --provenance=false -f php.sock.dockerfile --build-arg OS=$ARCH .         || exit
docker buildx build --tag ghcr.io/960018/php-fpm:testing-$ARCH-sock --push --compress --no-cache --sbom=false --provenance=false -f php.testing.sock.dockerfile --build-arg OS=$ARCH . || exit
