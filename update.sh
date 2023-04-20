#!/usr/bin/env bash

cd curl || exit
rm -rf src msrc
cd source || exit
git reset --hard; 
git pull; 
git submodule update --init --force;
cd .. || exit
cd msh3 || exit
git reset --hard; 
git pull; 
git submodule update --init --force;
cd .. || exit
cp -r source src
cd src || exit
rm -rf .git/ .github/
cd .. || exit
cp -r msh3 msrc
cd msrc || exit
rm -rf .git/ .github/
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

exts=("phpredis" "phpiredis" "runkit7" "xdebug")

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

docker pull mlocati/php-extension-installer
docker pull eqalpha/keydb:latest
docker pull debian:sid-slim
docker pull nginx:1.24-bullseye
docker pull node:19-bullseye-slim
