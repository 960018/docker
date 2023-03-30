#!/bin/sh

sh update.sh

docker buildx build --tag ghcr.io/960018/debian:base-macos --push --compress --no-cache -f Dockerfile.debian.base . || exit
docker buildx build --tag ghcr.io/960018/debian:curl-macos --push --compress --no-cache -f Dockerfile.debian.curl --build-arg OS=macos . || exit
docker buildx build --tag ghcr.io/960018/debian:nginx-macos --push --compress --no-cache -f Dockerfile.debian.nginx . || exit
