#!/usr/bin/env bash

PLATFORM=$(uname -m)

case $PLATFORM in 
    x86_64)
        ARCH=amd64
        ;;
    arm64)
        ARCH=macos
        ;;
    aarch64)
        ARCH=arm64
        ;;
    *)
        exit
        ;;
esac

export ARCH

docker login ghcr.io -u "$CR_USER" --password "$CR_PAT"

source .env

docker pull "traefik:$TRAEFIK"
docker pull "ghcr.io/960018/keydb:$ARCH"
docker pull "postgres:$POSTGRES13"
docker pull "postgres:$POSTGRES14"
docker pull "postgres:$POSTGRES15"

docker compose -f docker-compose.start.yml up -d --force-recreate
