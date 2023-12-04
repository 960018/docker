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

docker pull "portainer/agent:$PORTAINER" || exit
docker pull "portainer/portainer-ce:$PORTAINER" || exit
docker pull "dunglas/mercure:$MERCURE" || exit

if [ -z $(docker network ls --filter name=^frontend$ --format="{{ .Name }}") ]; then
    docker network create frontend;
fi

if [ -z $(docker network ls --filter name=^backend$ --format="{{ .Name }}") ]; then
    docker network create backend;
fi

docker compose --profile full -f docker-compose.extra.yaml down
docker compose -f docker-compose.extra.yaml up -d --force-recreate || exit
