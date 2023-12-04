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

docker compose -f docker-compose.extra.yaml down
