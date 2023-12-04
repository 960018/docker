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
export BOP="--push --compress --no-cache --shm-size=2gb --provenance=true --sbom=true --builder=master --progress plain --platform=linux/${ARCH}"

source .env

docker login ghcr.io -u "$CR_USER" --password "$CR_PAT" || exit

docker rm -f buildx_buildkit_master0

docker buildx build --tag ghcr.io/960018/scratch:latest             ${BOP} -f scratch.dockerfile .                               || exit
docker pull ghcr.io/960018/scratch:latest
docker buildx build --tag ghcr.io/960018/nginx:$ARCH                ${BOP} -f nginx.dockerfile .                                 || exit
docker buildx build --tag ghcr.io/960018/keydb:$ARCH                ${BOP} -f keydb.dockerfile .                                 || exit
docker buildx build --tag ghcr.io/960018/bun:$ARCH                  ${BOP} -f bun.dockerfile .                                   || exit

docker buildx build --tag ghcr.io/960018/node:20-$ARCH              ${BOP} -f node.dockerfile --build-arg VERSION=$NODE20 .      || exit
docker buildx build --tag ghcr.io/960018/node:21-$ARCH              ${BOP} -f node.dockerfile --build-arg VERSION=$NODE21 .      || exit
docker buildx build --tag ghcr.io/960018/node:18-$ARCH              ${BOP} -f node.dockerfile --build-arg VERSION=$NODE18 .      || exit
docker pull ghcr.io/960018/node:21-$ARCH
docker buildx build --tag ghcr.io/960018/node:21-$ARCH-ip           ${BOP} -f node.ip.dockerfile --build-arg OS=$ARCH .          || exit
docker buildx build --tag ghcr.io/960018/node:21-$ARCH-echo         ${BOP} -f node.echo.dockerfile --build-arg OS=$ARCH .        || exit

docker buildx build --tag ghcr.io/960018/curl:$ARCH                 ${BOP} -f curl.dockerfile .                                  || exit
docker pull ghcr.io/960018/curl:$ARCH
docker buildx build --tag ghcr.io/960018/php-fpm:$ARCH              ${BOP} -f php.dockerfile --build-arg OS=$ARCH .              || exit
docker pull ghcr.io/960018/php-fpm:$ARCH
docker buildx build --tag ghcr.io/960018/php-fpm:testing-$ARCH      ${BOP} -f php.testing.dockerfile --build-arg OS=$ARCH .      || exit

docker buildx build --tag ghcr.io/960018/php-fpm:$ARCH-sock         ${BOP} -f php.sock.dockerfile --build-arg OS=$ARCH .         || exit
docker pull ghcr.io/960018/php-fpm:testing-$ARCH
docker buildx build --tag ghcr.io/960018/php-fpm:testing-$ARCH-sock ${BOP} -f php.testing.sock.dockerfile --build-arg OS=$ARCH . || exit
