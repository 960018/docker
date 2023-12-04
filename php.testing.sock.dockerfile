ARG     OS

FROM    ghcr.io/960018/php-fpm:testing-${OS}

USER    root

RUN     \
        set -eux \
&&      sed -i -e "s/listen = 9000/listen = \/tmp\/docker\/php-fpm.sock/g" /usr/local/etc/php-fpm.d/www.conf

USER    vairogs

ENV     FCGI_CONNECT=/tmp/docker/php-fpm.sock
