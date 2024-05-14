#!/usr/bin/env bash

source .env

cd curl || exit
rm -rf src
cd source || exit
git reset --hard;
git pull;
git submodule update --init --force;
cd .. || exit
cp -r source src
cd src || exit
rm -rf .git/ .github/
cd .. || exit
cd clone || exit

subs=("nghttp3" "ngtcp2" "wolfssl")

for j in "${subs[@]}"
do
    cd "$j" || exit
    git reset --hard;
    git pull;
    git submodule update --init --force;
    cd .. || exit
    rm -rf "${j}src"
    cp -r "$j" "${j}src"
    cd "${j}src" || exit
    rm -rf .git/ .github/
    cd .. || exit
done

cd .. || exit
cd .. || exit

cd php || exit
rm -rf src
cd source || exit
git reset --hard; 
git pull; 
git submodule update --init --force;
cd .. || exit
cp -r source src
cd src || exit
rm -rf .git/ .github/
cd .. || exit
cd clone || exit

exts=("phpredis" "phpiredis" "runkit7" "xdebug" "php-spx" "imagick" "apcu" "ext-ds" "pecl-event" "php_zip")

for i in "${exts[@]}"
do
    cd "$i" || exit
    git reset --hard; 
    git pull; 
    git submodule update --init --force;
    cd .. || exit
    rm -rf "${i}src"
    cp -r "$i" "${i}src"
    cd "${i}src" || exit
    rm -rf .git/ .github/
    cd .. || exit
done

cd .. || exit
cd .. || exit

docker pull mlocati/php-extension-installer:latest || exit
docker pull composer:latest || exit
docker pull eqalpha/keydb:latest || exit
docker pull debian:sid-slim || exit
docker pull nginx:1.26-bookworm || exit
docker pull "node:${NODE21}-bookworm-slim" || exit
docker pull "node:${NODE18}-bookworm-slim" || exit
docker pull "node:${NODE22}-bookworm-slim" || exit
docker pull oven/bun:canary || exit
docker pull moby/buildkit:master-rootless || exit
docker pull "varnish:${VARNISH}" || exit
