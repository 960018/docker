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

docker login ghcr.io -u "$CR_USER" --password "$CR_PAT"                                                                                               || exit

docker rm -f buildx_buildkit_master0                                                                                                                  || exit

docker buildx build --tag ghcr.io/960018/scratch:$ARCH              ${BOP} -f scratch.dockerfile .                                                    || exit
docker pull ghcr.io/960018/scratch:$ARCH                                                                                                              || exit

docker buildx build --tag ghcr.io/960018/nginx:$ARCH                ${BOP} -f nginx.dockerfile --build-arg ARCH=$ARCH --build-arg VERSION=$NGINX .    || exit

docker buildx build --tag ghcr.io/960018/keydb:$ARCH                ${BOP} -f keydb.dockerfile --build-arg ARCH=$ARCH .                               || exit

docker buildx build --tag ghcr.io/960018/bun:$ARCH                  ${BOP} -f bun.dockerfile --build-arg ARCH=$ARCH .                                 || exit

docker buildx build --tag ghcr.io/960018/node:22-$ARCH              ${BOP} -f node.dockerfile --build-arg VERSION=$NODE22 --build-arg ARCH=$ARCH .    || exit

docker pull ghcr.io/960018/node:22-$ARCH                                                                                                              || exit
docker buildx build --tag ghcr.io/960018/node:22-$ARCH-ip           ${BOP} -f node.script.dockerfile --build-arg ARCH=$ARCH --build-arg SCRIPT=ip .   || exit
docker buildx build --tag ghcr.io/960018/node:22-$ARCH-echo         ${BOP} -f node.script.dockerfile --build-arg ARCH=$ARCH --build-arg SCRIPT=echo . || exit

docker buildx build --tag ghcr.io/960018/valkey-base:$ARCH          ${BOP} -f valkey.base.dockerfile .                                                || exit
docker buildx build --tag ghcr.io/960018/valkey:$ARCH               ${BOP} -f valkey.dockerfile --build-arg ARCH=$ARCH .                              || exit

docker buildx build --tag ghcr.io/960018/curl:$ARCH                 ${BOP} -f curl.dockerfile --build-arg ARCH=$ARCH .                                || exit
docker pull ghcr.io/960018/curl:$ARCH                                                                                                                 || exit

docker buildx build --tag ghcr.io/960018/php-fpm:$ARCH              ${BOP} -f php.dockerfile --build-arg ARCH=$ARCH .                                 || exit
docker pull ghcr.io/960018/php-fpm:$ARCH                                                                                                              || exit
docker buildx build --tag ghcr.io/960018/php-fpm:testing-$ARCH      ${BOP} -f php.testing.dockerfile --build-arg ARCH=$ARCH .                         || exit
docker buildx build --tag ghcr.io/960018/php-fpm:$ARCH-sock         ${BOP} -f php.sock.dockerfile --build-arg ARCH=$ARCH .                            || exit
docker pull ghcr.io/960018/php-fpm:testing-$ARCH                                                                                                      || exit
docker buildx build --tag ghcr.io/960018/php-fpm:testing-$ARCH-sock ${BOP} -f php.testing.sock.dockerfile --build-arg ARCH=$ARCH .                    || exit

#docker pull ghcr.io/960018/nginx:$ARCH                                                                                                                || exit
#docker buildx build --tag ghcr.io/960018/builder:$ARCH              ${BOP} -f builder.dockerfile --build-arg ARCH=$ARCH .                             || exit
#docker buildx build --tag ghcr.io/960018/php-zts:$ARCH              ${BOP} -f php.zts.dockerfile --build-arg ARCH=$ARCH .                                 || exit

docker rm -f buildx_buildkit_master0                                                                                                                  || exit
