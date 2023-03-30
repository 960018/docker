#!/bin/sh

sh update.sh

docker buildx build --tag ghcr.io/960018/debian:base-arm64 --push --compress --no-cache -f Dockerfile.debian.base . || exit
docker buildx build --tag ghcr.io/960018/debian:curl-arm64 --push --compress --no-cache -f Dockerfile.debian.curl --build-arg OS=arm64 . || exit
docker buildx build --tag ghcr.io/960018/debian:nginx-arm64 --push --compress --no-cache -f Dockerfile.debian.nginx . || exit
