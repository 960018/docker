#!/usr/bin/env bash

cd curl
rm -rf src msrc
cd source
git reset --hard; 
git pull; 
git submodule update --init --force;
cd ..
cd msh3
git reset --hard; 
git pull; 
git submodule update --init --force;
cd ..
cp -r source src
cd src
rm -rf .git/ .github/
cd ..
cp -r msh3 msrc
cd msrc
rm -rf .git/ .github/
cd ..
cd ..

# cd keydb
# rm -rf src
# cd source
# git reset --hard; 
# git pull; 
# git submodule update --init --force;
# cd ..
# cp -r source src
# cd src
# rm -rf .git/ .github/
# cd ..
# cd ..

# cd traefik
# rm -rf src
# cd source
# git reset --hard; 
# git pull; 
# git submodule update --init --force;
# cd ..
# cp -r source src
# cd src
# rm -rf .github/ .dist/
# sed -i 's/ARG DOCKER_VERSION=18.09.7/ARG DOCKER_VERSION=23.0.2/g' build.Dockerfile
# sed -i 's/static\/stable\/x86_64/static\/test\/aarch64/g' build.Dockerfile
# sed -i 's/apk --no-cache --no-progress/apk --no-cache --no-progress --upgrade --update -X http:\/\/dl-cdn.alpinelinux.org\/alpine\/edge\/testing/g' build.Dockerfile
# cd ..
# cd ..

# cd php
# rm -rf src
# cd source
# git reset --hard; 
# git pull; 
# git submodule update --init --force;
# cd ..
# cp -r source src
# cd src
# rm -rf .git/ .github/
# cd ..
# cd ..

# cd nginx
# rm -rf src
# cd source
# git reset --hard; 
# git pull; 
# git submodule update --init --force;
# cd ..
# cp -r source src
# cd src
# rm -rf .git/ .github/
# cd ..
# cd ..
