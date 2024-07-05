ARG     ARCH

FROM    ghcr.io/960018/php-fpm:${ARCH} AS builder

USER    root

ENV     PHP_VERSION=8.4.0-dev
ENV     PHP_INI_DIR=/usr/local/etc/php
ENV     PHP_CFLAGS="-fstack-protector-strong -fpic -fpie -O3 -ftree-vectorize -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64 -march=native -mcpu=native"
ENV     PHP_CPPFLAGS="$PHP_CFLAGS"
ENV     PHP_LDFLAGS="-Wl,-O3 -pie"

COPY    php/docker/docker-php-ext-enable /usr/local/bin/docker-php-ext-enable

COPY    php/clone/xdebugsrc/   /home/vairogs/extensions/xdebug/
COPY    php/clone/runkit7src/ /home/vairogs/extensions/runkit7/
COPY    php/clone/php-spxsrc/ /home/vairogs/extensions/php-spx/

RUN     \
        set -eux \
&&      chmod -R 1777 /usr/local/bin \
&&      mkdir --parents /home/vairogs/extensions

WORKDIR /home/vairogs/extensions

RUN     \
        set -eux \
&&      apt-get update \
&&      apt-get upgrade -y \
&&      apt-get install -y --no-install-recommends --allow-downgrades autoconf dpkg-dev dpkg file make libc-dev libc6-dev cpp gcc g++ pkgconf re2c bison \
            zlib1g-dev zlib1g libmagickwand-6.q16-7t64 \
&&      ( \
            cd xdebug \
            &&  phpize \
            &&  autoupdate \
            &&  ./configure --enable-xdebug \
            &&  make \
            &&  make install \
            &&  cd .. || exit \
        ) \
&&      docker-php-ext-enable xdebug \
&&      ( \
             cd  runkit7 \
             &&  phpize \
             &&  ./configure \
             &&  make \
             &&  make install \
             &&  cd .. || exit \
         ) \
&&      docker-php-ext-enable runkit7 \
&&      ( \
             cd  php-spx \
             &&  phpize \
             &&  ./configure \
             &&  make \
             &&  make install \
             &&  cd .. || exit \
         ) \
&&      docker-php-ext-enable spx \
&&      echo xdebug.mode=debug,coverage >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
&&      echo xdebug.discover_client_host=0 >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
&&      echo xdebug.client_host=host.docker.internal >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
&&      echo xdebug.start_with_request=trigger >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
&&      echo xdebug.log=/tmp/xdebug.log >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
&&      echo runkit.internal_override=1 >> /usr/local/etc/php/conf.d/docker-php-ext-runkit7.ini \
&&      echo spx.http_enabled=1 >> /usr/local/etc/php/conf.d/docker-php-ext-spx.ini \
&&      echo spx.http_key="vairogs" >> /usr/local/etc/php/conf.d/docker-php-ext-spx.ini \
&&      echo spx.http_ip_whitelist="*" >> /usr/local/etc/php/conf.d/docker-php-ext-spx.ini \
&&      echo spx.http_ui_assets_dir=/usr/share/misc/php-spx/assets/web-ui >> /usr/local/etc/php/conf.d/docker-php-ext-spx.ini \
&&      echo spx.http_trusted_proxies="*" >> /usr/local/etc/php/conf.d/docker-php-ext-spx.ini \
&&      sed -i -e "s/zlib.output_compression_level = 9/zlib.output_compression_level = 0/g" /usr/local/etc/php/conf.d/docker-php-ext-zlib.ini \
&&      sed -i -e "s/zlib.output_compression = 4096/zlib.output_compression = Off/g" /usr/local/etc/php/conf.d/docker-php-ext-zlib.ini \
&&      echo 'alias upd="composer update -nW --ignore-platform-reqs"' >> /home/vairogs/.bashrc \
&&      echo 'alias ins="composer install -n --ignore-platform-reqs"' >> /home/vairogs/.bashrc \
&&      echo 'alias req="composer require -nW --ignore-platform-reqs"' >> /home/vairogs/.bashrc \
&&      echo 'alias rem="composer remove -nW --ignore-platform-reqs"' >> /home/vairogs/.bashrc \
&&      apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false autoconf dpkg-dev make libc-dev libc6-dev file \
            pkgconf re2c bison cpp gcc g++ gcc-13 cpp-13 fontconfig zlib1g-dev \
&&      apt-get autoremove -y --purge \
&&      mkdir --parents /usr/share/misc/php-spx \
&&      cp -r php-spx/assets /usr/share/misc/php-spx \
&&      chown -R vairogs:vairogs /usr/share/misc/php-spx \
&&      rm -rf \
            /*.deb \
            /home/vairogs/*.deb \
            /home/vairogs/*.gz \
            /home/vairogs/extensions \
            /home/vairogs/installer \
            /tmp/* \
            /usr/local/bin/docker-php-ext-enable \
            /usr/local/bin/phpdbg \
            /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini \
            /usr/local/etc/php/php.ini-development \
            /usr/local/etc/php/php.ini-production \
            /usr/local/php/man/* \
            /usr/src/php \
            /var/cache/* \
            ~/.pearrc \
            /tmp/* \
            /usr/share/vim/vim90/doc \
            /usr/share/man/* \
&&      chown -R vairogs:vairogs /home/vairogs

COPY    php/exts/opcache.jit.ini /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini

WORKDIR /var/www/html

USER    vairogs

CMD     ["sh", "-c", "cron && php-fpm"]

FROM    ghcr.io/960018/bun:${ARCH} AS bun
FROM    ghcr.io/960018/scratch:${ARCH}

COPY    --from=builder / /
COPY    --from=bun /usr/local/bin/bun /usr/local/bin
COPY    --from=bun /usr/local/bin/bunx /usr/local/bin

ENV     PHP_VERSION=8.4.0-dev
ENV     PHP_INI_DIR=/usr/local/etc/php
ENV     PHP_CFLAGS="-fstack-protector-strong -fpic -fpie -O3 -ftree-vectorize -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64 -march=native -mcpu=native"
ENV     PHP_CPPFLAGS="$PHP_CFLAGS"
ENV     PHP_LDFLAGS="-Wl,-O3 -pie"
ENV     PHP_CS_FIXER_IGNORE_ENV=1

STOPSIGNAL SIGQUIT

WORKDIR /var/www/html

EXPOSE  9000

RUN     \
        set -eux \
&&      git config --global --add safe.directory "*"

ENTRYPOINT ["docker-php-entrypoint"]

CMD     ["sh", "-c", "cron && php-fpm"]
