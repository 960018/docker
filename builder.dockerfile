ARG     ARCH

FROM    ghcr.io/960018/node:21-${ARCH} AS node
FROM    ghcr.io/960018/nginx:${ARCH} AS nginx
FROM    ghcr.io/960018/php-fpm:${ARCH}-sock

USER    root

ENV     PHP_VERSION 8.4.0-dev
ENV     PHP_INI_DIR /usr/local/etc/php
ENV     PHP_CFLAGS "-fstack-protector-strong -fpic -fpie -O3 -ftree-vectorize -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64 -march=native -mcpu=native"
ENV     PHP_CPPFLAGS "$PHP_CFLAGS"
ENV     PHP_LDFLAGS "-Wl,-O3 -pie"

WORKDIR /var/www/html

COPY    --from=node /usr/local/bin/node /usr/local/bin
COPY    --from=node /usr/local/bin/yarn /usr/local/bin
COPY    --from=nginx /docker-entrypoint.sh /
COPY    --from=nginx /docker-entrypoint.d/* /docker-entrypoint.d
COPY    --from=nginx /etc/nginx/* /etc/nginx
COPY    --from=nginx /usr/sbin/nginx /usr/sbin
COPY    ./builder/cmd.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD     ["/cmd.sh"]

RUN    \
        set -eux \
&&      mkdir -p /var/log/nginx \
&&      touch /var/log/nginx/error.log \
&&      touch /var/log/nginx/access.log \
&&      chown -R vairogs:vairogs /var \
&&      touch /var/run/nginx.pid \
&&      chown -R vairogs:vairogs /var/run/nginx.pid \
&&      chmod +x /cmd.sh \
&&      mkdir -p /tmp/sockets

EXPOSE  80
EXPOSE  443/tcp
EXPOSE  443/udp

USER    vairogs
