#!/usr/bin/env bash

cd curl || exit
rm -rf source src
eval "$(cat curl.txt)"
cd clone || exit

subs=("nghttp3" "ngtcp2" "wolfssl")

for j in "${subs[@]}"
do
    rm -rf "$j"
    eval "$(cat "${j}.txt")"
done

cd .. || exit
cd .. || exit

cd php || exit

wget -cN "https://raw.githubusercontent.com/mlocati/docker-php-extension-installer/master/install-php-extensions"

rm -rf source src
eval "$(cat php.txt)"
cd clone || exit

exts=("phpredis" "phpiredis" "runkit7" "xdebug" "php-spx" "imagick" "apcu" "ext-ds" "pecl-event" "php_zip")

for i in "${exts[@]}"
do
    rm -rf "$i"
    eval "$(cat "${i}.txt")"
done

cd .. || exit
cd .. || exit
