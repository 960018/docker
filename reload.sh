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
docker pull "memcached:$MEMCACHED" || exit
docker pull "busybox:uclibc" || exit

if [ -z $(docker network ls --filter name=^frontend$ --format="{{ .Name }}") ]; then
    docker network create frontend;
fi

if [ -z $(docker network ls --filter name=^backend$ --format="{{ .Name }}") ]; then
    docker network create backend;
fi

dirs=("socks" "postgres13" "postgres14" "postgres15" "postgres16")

for i in "${dirs[@]}"
do
    if [ -z $(docker volume ls -f name=$i | awk '{print $NF}' | grep -E "^$i") ]; then
        docker volume create "$i";
    fi
done

PROFILE=${1:-'full'}

docker compose --profile full -f docker-compose.start.yaml down
docker kill $(docker ps -q)
docker compose --profile $PROFILE -f docker-compose.start.yaml up -d --force-recreate || exit
