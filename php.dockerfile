ARG     ARCH

FROM    ghcr.io/960018/curl:${ARCH} AS builder

ARG     ARCH

USER    root

ENV     PHP_VERSION=8.4.0-dev
ENV     PHP_INI_DIR=/usr/local/etc/php
ENV     PHP_CFLAGS="-fstack-protector-strong -fpic -fpie -O3 -ftree-vectorize -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64 -march=native -mtune=native"
ENV     PHP_CPPFLAGS="$PHP_CFLAGS"
ENV     PHP_LDFLAGS="-Wl,-O3 -pie"

COPY    php/no-debian-php /etc/apt/preferences.d/no-debian-php
COPY    php/src/          /usr/src/php

COPY    php/docker/docker-php-entrypoint    /usr/local/bin/docker-php-entrypoint
COPY    php/docker/docker-php-ext-configure /usr/local/bin/docker-php-ext-configure
COPY    php/docker/docker-php-ext-enable    /usr/local/bin/docker-php-ext-enable
COPY    php/docker/docker-php-ext-install   /usr/local/bin/docker-php-ext-install
COPY    php/docker/docker-php-source        /usr/local/bin/docker-php-source
COPY    php/install-php-extensions          /usr/local/bin/install-php-extensions
COPY    --from=composer:latest              /usr/bin/composer /usr/bin/

ENTRYPOINT ["docker-php-entrypoint"]

STOPSIGNAL SIGQUIT

WORKDIR /home/vairogs

RUN     \
        set -eux \
&&      apt-get update \
&&      apt-get upgrade -y \
&&      apt-get install -y --no-install-recommends --allow-downgrades make libc-dev libc6-dev gcc g++ cpp bison git dpkg-dev autoconf re2c libxml2-dev libxml2 libsqlite3-dev libsqlite3-0 xz-utils libargon2-dev libargon2-1 \
            libonig-dev libonig5 libsodium-dev libsodium23 zlib1g-dev zlib1g libbz2-dev libbz2-1.0 libgmp-dev libgmp10 libedit-dev libedit2 libtidy-dev libtidy58 libnghttp3-dev libnghttp3-9 valgrind \
            libnghttp2-dev nghttp2 idn2 libidn2-0 librtmp-dev librtmp1 rtmpdump libgsasl-dev libgsasl18 libpsl-dev libpsl5t64 zstd libzstd-dev libbrotli1 libbrotli-dev libjpeg62-turbo libjpeg62-turbo-dev libpng16-16t64 libpng-dev \
            libwebp7 libwebp-dev libfreetype-dev libfreetype6 liblzf-dev liblzf1 liblzf-dev liblzf1 liblz4-dev liblzf-dev liblz4-1 gdb-minimal libfcgi-bin wget cron libssl-dev libssl3t64 libhiredis1.1.0 libhiredis-dev libpq5 libpq-dev \
            libzip4t64 libzip-dev libmagickwand-6.q16-dev libmagickwand-6.q16-7t64 libmagickcore-6.q16-7t64 libmagickcore-6.q16-dev libevent-2.1-7t64 libevent-openssl-2.1-7t64 libevent-extra-2.1-7t64 libevent-core-2.1-7t64 libevent-pthreads-2.1-7t64 libevent-dev \
&&      chmod -R 1777 /usr/local/bin \
&&      mkdir --parents "$PHP_INI_DIR/conf.d" \
&&      [ ! -d /var/www/html ]; \
        mkdir --parents /var/www/html \
&&      chown vairogs:vairogs /var/www/html \
&&      chmod 1777 -R /var/www/html \
&&      export \
            CFLAGS="$PHP_CFLAGS" \
            CPPFLAGS="$PHP_CPPFLAGS" \
            LDFLAGS="$PHP_LDFLAGS" \
&&      cd /usr/src/php \
&&      gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)" \
&&      ./buildconf --force \
&&      ./configure \
            --build="${gnuArch}" \
            --with-config-file-path="$PHP_INI_DIR" \
            --with-config-file-scan-dir="$PHP_INI_DIR/conf.d" \
            --disable-cgi \
            --disable-ftp \
            --disable-short-tags \
            --disable-mysqlnd \
            --disable-phpdbg \
            --enable-bcmath \
            --enable-calendar \
            --enable-exif \
            --enable-fpm \
            --enable-huge-code-pages \
            --enable-intl \
            --enable-mbstring \
            --enable-opcache \
            --enable-option-checking=fatal \
#            --enable-pcntl \
            --enable-sysvsem \
            --enable-sysvshm \
            --enable-sysvmsg \
            --enable-shmop \
            --enable-soap \
            --enable-sockets \
            --with-bz2 \
            --with-curl \
            --with-fpm-group=vairogs \
            --with-fpm-user=vairogs \
            --with-gmp \
#            --with-libedit \
            --with-mhash \
            --with-openssl \
            --with-password-argon2 \
            --with-pear \
            --with-pic \
            --with-pdo-pgsql \
            --with-pdo-sqlite=/usr \
            --with-sodium=shared \
            --with-sqlite3=/usr \
            --with-tidy \
            --with-valgrind \
            --with-zlib \
            --without-readline \
&&      make \
&&      find -type f -name '*.a' -delete \
&&      make install \
&&      find /usr/local -type f -perm '/0111' -exec sh -euxc ' strip --strip-all "$@" || : ' -- '{}' + \
&&      make clean \
&&      mkdir --parents "$PHP_INI_DIR" \
&&      cp -v php.ini-* "$PHP_INI_DIR/" \
&&      cd / \
&&      pecl update-channels \
&&      rm -rf \
            /tmp/pear \
            ~/.pearrc \
&&      php --version \
&&      mkdir --parents "$PHP_INI_DIR/conf.d" \
&&      chmod -R 1777 /usr/local/bin \
&&      docker-php-ext-enable sodium \
&&      mkdir --parents --mode=777 --verbose /run/php-fpm \
&&      touch /run/php-fpm/.keep_dir \
&&      composer self-update --snapshot \
&&      mkdir --parents /home/vairogs/extensions

COPY    php/clone/phpredissrc/ /home/vairogs/extensions/phpredis/
COPY    php/clone/phpiredissrc/ /home/vairogs/extensions/phpiredis/
COPY    php/clone/imagicksrc/ /home/vairogs/extensions/imagick/
COPY    php/clone/apcusrc/ /home/vairogs/extensions/apcu/
COPY    php/clone/pecl-eventsrc/ /home/vairogs/extensions/pecl-event/
COPY    php/clone/ext-dssrc/ /home/vairogs/extensions/ext-ds/
COPY    php/clone/php_zipsrc/ /home/vairogs/extensions/php_zip/
COPY    php/clone/mediawiki-php-excimersrc/ /home/vairogs/extensions/mediawiki-php-excimer/

WORKDIR /home/vairogs/extensions

RUN     \
        set -eux \
&&      chmod -R 1777 /usr/local/bin \
&&      export CFLAGS="$PHP_CFLAGS" CPPFLAGS="$PHP_CPPFLAGS" LDFLAGS="$PHP_LDFLAGS" PHP_BUILD_PROVIDER='https://github.com/960018/docker' PHP_UNAME="Linux (${ARCH}) - Docker" \
&&      docker-php-ext-configure gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/ --with-webp=/usr/include/ \
&&      docker-php-ext-install gd \
&&      docker-php-ext-enable gd

RUN     \
        set -eux \
&&      ( \
            cd  apcu \
            &&  phpize \
            &&  ./configure --enable-apcu \
            &&  make \
            &&  make install \
            &&  cd .. || exit \
        ) \
&&      docker-php-ext-enable apcu

#&&      install-php-extensions krakjoe/apcu@master \
#&&      install-php-extensions php-decimal/ext-decimal@master \
#&&      install-php-extensions php-ds/ext-ds@master \

RUN     \
        set -eux \
&&      install-php-extensions ev

#&&      install-php-extensions event \

RUN     \
        set -eux \
&&      install-php-extensions igbinary/igbinary@master
#&&      install-php-extensions Imagick/imagick@develop \

RUN     \
        set -eux \
&&      install-php-extensions inotify

RUN     \
        set -eux \
&&      install-php-extensions lz4

RUN     \
        set -eux \
&&      install-php-extensions lzf
#&&      install-php-extensions php-memcached-dev/php-memcached@master \

RUN     \
        set -eux \
&&      install-php-extensions msgpack

RUN     \
        set -eux \
&&      install-php-extensions simdjson

#RUN     \
#        set -eux \
#&&      install-php-extensions yac

RUN     \
        set -eux \
&&      install-php-extensions uuid

#RUN     \
#        set -eux \
#&&      install-php-extensions yaml

#RUN     \
#        set -eux \
#&&      install-php-extensions zip

RUN     \
        set -eux \
&&      install-php-extensions zstd

RUN     \
        set -eux \
&&      wget -O /usr/local/bin/php-fpm-healthcheck https://raw.githubusercontent.com/renatomefi/php-fpm-healthcheck/master/php-fpm-healthcheck \
&&      chmod +x /usr/local/bin/php-fpm-healthcheck \
&&      chown www-data:www-data /usr/local/bin/php-fpm-healthcheck

RUN     \
        set -eux \
&&      ( \
            cd  php_zip \
            &&  phpize \
            &&  ./configure --enable-zip --with-libzip \
            &&  make \
            &&  make install \
            &&  cd .. || exit \
        ) \
&&      docker-php-ext-enable zip \
&&      ( \
            cd  phpredis \
            &&  phpize \
            &&  ./configure --enable-redis-igbinary --enable-redis-zstd --enable-redis-msgpack --enable-redis-lzf --with-liblzf --enable-redis-lz4 --with-liblz4 \
            &&  make \
            &&  make install \
            &&  cd .. || exit \
        ) \
&&      docker-php-ext-enable redis \
&&      ( \
            cd  phpiredis \
            &&  phpize \
            &&  ./configure --enable-phpiredis \
            &&  make \
            &&  make install \
            &&  cd .. || exit \
        ) \
&&      docker-php-ext-enable phpiredis \
&&      ( \
            cd  imagick \
            &&  phpize \
            &&  ./configure --with-imagick \
            &&  make \
            &&  make install \
            &&  cd .. || exit \
        ) \
&&      docker-php-ext-enable imagick \
&&      ( \
            cd  ext-ds \
            &&  phpize \
            &&  ./configure \
            &&  make \
            &&  make install \
            &&  cd .. || exit \
        ) \
&&      docker-php-ext-enable ds \
&&      ( \
            cd  pecl-event \
            &&  phpize \
            &&  ./configure --with-event-core --with-event-extra \
            &&  make \
            &&  make install \
            &&  cd .. || exit \
        ) \
&&      docker-php-ext-enable event \
&&      ( \
            cd  mediawiki-php-excimer \
            &&  phpize \
            &&  ./configure \
            &&  make \
            &&  make install \
            &&  cd .. || exit \
        ) \
&&      docker-php-ext-enable excimer \
&&      apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false make libc-dev libc6-dev cpp gcc g++ autoconf dpkg-dev re2c bison libxml2-dev libssl-dev libsqlite3-dev xz-utils libargon2-dev \
            libnghttp3-dev libonig-dev libsodium-dev zlib1g-dev libbz2-dev libgmp-dev libedit-dev libtidy-dev libnghttp2-dev librtmp-dev libgsasl-dev libpsl-dev libzstd-dev libcrypt-dev \
            libbrotli-dev libjpeg62-turbo-dev libpng-dev libwebp-dev libfreetype-dev liblz4-dev liblzf-dev pkgconf make icu-devtools libbsd-dev libc-dev-bin libc6-dev libgssglue-dev libhiredis-dev libicu-dev \
            libidn-dev libidn2-dev libmd-dev libncurses-dev libntlm0-dev libp11-kit-dev libtasn1-6-dev linux-libc-dev cpp-14 gcc-14 fontconfig libpq-dev \
            libzip-dev libmagickwand-6.q16-dev libmagickcore-6.q16-dev libevent-dev \
&&      apt-get autoremove -y --purge \
&&      rm -rf \
            ~/.pearrc \
            /home/vairogs/extensions \
            /home/vairogs/*.deb \
            /home/vairogs/*.gz \
            /*.deb \
            /tmp/* \
            /usr/local/bin/docker-php-ext-configure \
            /usr/local/bin/docker-php-ext-enable \
            /usr/local/bin/docker-php-ext-install \
            /usr/local/bin/docker-php-source \
            /usr/local/bin/phpdbg \
            /usr/local/etc/php-fpm.conf \
            /usr/local/etc/php-fpm.d/* \
            /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini \
            /usr/local/etc/php/php.ini \
            /usr/local/php/man/* \
            /usr/src/php \
            /var/cache/* \
            /usr/local/etc/php/php.ini-development \
            /usr/local/etc/php/php.ini-production \
            /usr/share/vim/vim90/doc \
            /usr/local/bin/install-php-extensions \
            /usr/share/man/* \
&&      mkdir --parents /var/lib/php/sessions \
&&      chown -R vairogs:vairogs /var/lib/php/sessions \
&&      mkdir --parents /var/lib/php/opcache \
&&      chown -R vairogs:vairogs /var/lib/php/opcache

COPY    php/php-fpm.conf /usr/local/etc/php-fpm.conf
COPY    php/www.conf /usr/local/etc/php-fpm.d/www.conf
COPY    php/php.ini-development /usr/local/etc/php/php.ini
COPY    php/exts/opcache.ini /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini
COPY    php/preload.php /var/www/preload.php

RUN     \
        set -eux \
&&      chmod 644 /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini \
&&      echo zlib.output_compression = 4096 >> /usr/local/etc/php/conf.d/docker-php-ext-zlib.ini \
&&      echo zlib.output_compression_level = 9 >> /usr/local/etc/php/conf.d/docker-php-ext-zlib.ini \
&&      git config --global --add safe.directory "*" \
&&      chown -R vairogs:vairogs /home/vairogs \
&&      chmod u+s /usr/sbin/cron

WORKDIR /var/www/html

USER    vairogs

CMD     ["sh", "-c", "cron && php-fpm"]

FROM    ghcr.io/960018/scratch:${ARCH}

COPY    --from=builder / /

ENV     PHP_VERSION=8.4.0-dev
ENV     PHP_INI_DIR=/usr/local/etc/php
ENV     PHP_CFLAGS="-fstack-protector-strong -fpic -fpie -O3 -ftree-vectorize -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64 -march=native -mtune=native"
ENV     PHP_CPPFLAGS="$PHP_CFLAGS"
ENV     PHP_LDFLAGS="-Wl,-O3 -pie"
ENV     PHP_CS_FIXER_IGNORE_ENV=1

STOPSIGNAL SIGQUIT

WORKDIR /var/www/html

EXPOSE  9000

ENTRYPOINT ["docker-php-entrypoint"]

CMD     ["sh", "-c", "cron && php-fpm"]
