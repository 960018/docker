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
docker pull "postgres:$POSTGRES16" || exit

if [ -z $(docker network ls --filter name=^frontend$ --format="{{ .Name }}") ]; then
    docker network create frontend;
fi

if [ -z $(docker network ls --filter name=^backend$ --format="{{ .Name }}") ]; then
    docker network create backend;
fi

PROFILE=${1:-'full'}

docker compose --profile $PROFILE -f docker-compose.start.yml up -d --force-recreate || exit
