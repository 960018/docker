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

docker login ghcr.io -u "$CR_USER" --password "$CR_PAT" || exit

source .env

docker pull "traefik:$TRAEFIK" || exit
docker pull "ghcr.io/960018/keydb:$ARCH" || exit
docker pull "postgres:$POSTGRES13" || exit
docker pull "postgres:$POSTGRES14" || exit
docker pull "postgres:$POSTGRES15" || exit

docker compose -f docker-compose.start.yml up -d --force-recreate || exit
