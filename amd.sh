#!/bin/sh

sh update.sh

docker buildx build --tag ghcr.io/960018/debian:base-amd64 --push --compress --no-cache -f Dockerfile.debian.base . || exit
docker buildx build --tag ghcr.io/960018/debian:curl-amd64 --push --compress --no-cache -f Dockerfile.debian.curl --build-arg OS=amd64 . || exit
docker buildx build --tag ghcr.io/960018/debian:nginx-amd64 --push --compress --no-cache -f Dockerfile.debian.nginx . || exit
