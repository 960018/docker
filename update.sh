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

cd php
rm -rf src
cd source
git reset --hard; 
git pull; 
git submodule update --init --force;
cd ..
cp -r source src
cd src
rm -rf .git/ .github/
cd ..
cd clone

exts=("phpredis" "phpiredis" "runkit7" "xdebug")

for i in "${exts[@]}"
do
    cd "$i"
    git reset --hard; 
    git pull; 
    git submodule update --init --force;
    cd ..
    rm -rf "${i}src"
    cp -r "$i" "${i}src"
    cd "${i}src"
    rm -rf .git/ .github/
    cd ..
done

cd ..

docker pull mlocati/php-extension-installer
docker pull eqalpha/keydb:latest
docker pull debian:sid-slim
docker pull nginx:1.24-bullseye
docker pull node:19-bullseye-slim
