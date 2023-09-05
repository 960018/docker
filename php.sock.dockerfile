ARG     OS

FROM    ghcr.io/960018/php-fpm:$OS

USER    root

RUN     \
        set -eux \
&&      mkdir -p /var/www/sock \
&&      chown -R vairogs:vairogs /var/www/sock \
&&      sed -i -e "s/listen = 9000/listen = \/var\/www\/sock\/php-fpm.sock/g" /usr/local/etc/php-fpm.d/www.conf

USER    vairogs
