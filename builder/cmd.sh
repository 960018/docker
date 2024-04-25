#!/usr/bin/env bash

cron 2>&1
php-fpm 2>&1
nginx -g "daemon off;"
