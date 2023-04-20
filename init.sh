#!/usr/bin/env bash

cd curl || exit
rm -rf source src msh3 msrc
eval $(cat msh3.txt)
eval $(cat curl.txt)
cd .. || exit

cd php || exit
rm -rf source src
eval $(cat php.txt)
cd clone || exit

exts=("phpredis" "phpiredis" "runkit7" "xdebug")

for i in "${exts[@]}"
do
    rm -rf "$i"
    eval $(cat "${i}.txt")
done

cd .. || exit
cd .. || exit
