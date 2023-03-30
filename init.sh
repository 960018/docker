#!/usr/bin/env bash

cd  curl
rm -rf source src msh3 msrc
eval $(cat msh3.txt)
eval $(cat curl.txt)
cd ..

# cd keydb
# rm -rf source src
# eval $(cat keydb.txt)
# cd ..

# cd nginx
# rm -rf source src
# eval $(cat nginx.txt)
# cd ..

# cd php
# rm -rf source src
# eval $(cat php.txt)
# cd ..

# cd traefik
# rm -rf source src
# eval $(cat traefik.txt)
# cd ..

