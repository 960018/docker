ARG     OS

FROM    ghcr.io/960018/curl:$OS as builder

ARG     OS

USER    root

ENV     PHP_VERSION 8.3.0-dev
ENV     PHP_INI_DIR /usr/local/etc/php
ENV     PHP_CFLAGS "-fstack-protector-strong -fpic -fpie -O2 -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64"
ENV     PHP_CPPFLAGS "$PHP_CFLAGS"
ENV     PHP_LDFLAGS "-Wl,-O1 -pie"

COPY    php/no-debian-php /etc/apt/preferences.d/no-debian-php
COPY    php/ping.sh /usr/local/bin/php-fpm-ping
COPY    php/src/ /usr/src/php
COPY    php/installer /home/vairogs/installer
COPY    php/docker-php-entrypoint /usr/local/bin/docker-php-entrypoint
COPY    php/docker-php-ext-configure /usr/local/bin/docker-php-ext-configure
COPY    php/docker-php-ext-enable /usr/local/bin/docker-php-ext-enable
COPY    php/docker-php-ext-install /usr/local/bin/docker-php-ext-install
COPY    php/docker-php-source /usr/local/bin/docker-php-source

COPY    php/redis/ /home/vairogs/
COPY    --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/

ENTRYPOINT ["docker-php-entrypoint"]

STOPSIGNAL SIGQUIT

WORKDIR /home/vairogs

RUN     \
        set -eux \
&&      apt-get update \
&&      apt-get upgrade -y \
&&      apt-get install -y --no-install-recommends build-essential bison git autoconf dpkg-dev dpkg re2c libxml2-dev libxml2 libssl-dev libssl3 libsqlite3-dev libsqlite3-0 xz-utils libargon2-dev libargon2-1 \
        libonig-dev libonig5 libreadline-dev libreadline8 libsodium-dev libsodium23 zlib1g-dev zlib1g libbz2-dev libbz2-1.0 libgmp-dev libgmp10 libedit-dev libedit2 libtidy-dev libtidy5deb1 libnghttp3-dev libnghttp3-3 \
        libnghttp2-dev nghttp2 idn2 libidn2-0 librtmp-dev librtmp1 rtmpdump libgsasl-dev libgsasl18 libpsl-dev libpsl5 zstd libzstd-dev libbrotli1 libbrotli-dev libjpeg62-turbo libjpeg62-turbo-dev libpng16-16 libpng-dev \
        libwebp7 libwebp-dev libfreetype-dev libfreetype6 liblzf-dev liblzf1 liblzf-dev liblzf1 liblz4-dev liblzf-dev liblz4-1 \
&&      dpkg -i /home/vairogs/libhiredis-$OS.deb \
&&      dpkg -i /home/vairogs/libhiredis-dev-$OS.deb \
&&      chmod -R 777 /usr/local/bin \
&&      chmod 777 /home/vairogs/installer \
&&      mkdir --parents "$PHP_INI_DIR/conf.d" \
&&      [ ! -d /var/www/html ]; \
        mkdir --parents /var/www/html \
&&      chown vairogs:vairogs /var/www/html \
&&      chmod 777 -R /var/www/html \
&&      export \
            CFLAGS="$PHP_CFLAGS" \
            CPPFLAGS="$PHP_CPPFLAGS" \
            LDFLAGS="$PHP_LDFLAGS" \
&&      cd /usr/src/php \
&&      gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)" \
&&      ./buildconf --force \
&&      ./configure \
            --build="$gnuArch" \
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
            --enable-pcntl \
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
            --with-libedit \
            --with-mhash \
            --with-openssl \
            --with-password-argon2 \
            --with-pear \
            --with-pic \
            --with-pdo-sqlite=/usr \
            --with-readline \
            --with-sodium=shared \
    		--with-sqlite3=/usr \
            --with-tidy \
            --with-zlib \
&&      make -j "$(expr $(nproc) / 3)" \
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
&&      chmod -R 777 /usr/local/bin \
&&      docker-php-ext-enable sodium \
&&      mkdir --parents --mode=777 --verbose /run/php-fpm \
&&      mkdir --parents /var/www/html/config \
&&      touch /run/php-fpm/.keep_dir \
&&      cat /home/vairogs/installer | php -- --install-dir=/usr/local/bin --filename=composer \
&&      composer self-update --snapshot \
&&      export CFLAGS="$PHP_CFLAGS" CPPFLAGS="$PHP_CPPFLAGS" LDFLAGS="$PHP_LDFLAGS" \
&&      docker-php-ext-configure gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/ --with-webp=/usr/include/ \
&&      docker-php-ext-install gd \
&&      docker-php-ext-enable gd \
&&      mkdir --parents /home/vairogs/extensions \
&&      install-php-extensions php-memcached-dev/php-memcached@master inotify msgpack lzf pdo_pgsql pgsql zip krakjoe/apcu@master igbinary/igbinary@master Imagick/imagick@develop event

COPY    php/clone/phpredissrc/ /home/vairogs/extensions/phpredis/
COPY    php/clone/phpiredissrc/ /home/vairogs/extensions/phpiredis/

WORKDIR /home/vairogs/extensions

ARG     RELAY

RUN     \
        set -eux \
&&      ( \
            cd  phpredis \
            &&  phpize \
            &&  ./configure --enable-redis-igbinary --enable-redis-zstd --enable-redis-msgpack --enable-redis-lzf --with-liblzf --enable-redis-lz4 --with-liblz4 \
            &&  make -j "$(expr $(nproc) / 3)" \
            &&  make install \
            &&  cd .. || exit \
        ) \
&&      docker-php-ext-enable redis \
&&      ( \
            cd  phpiredis \
            &&  phpize \
            &&  ./configure --enable-phpiredis \
            &&  make -j "$(expr $(nproc) / 3)" \
            &&  make install \
            &&  cd .. || exit \
        ) \
&&      docker-php-ext-enable phpiredis \
&&      curl -L "https://builds.r2.relay.so/dev/relay-dev-php8.3-debian-$RELAY+libssl3.tar.gz" | tar xz -C /tmp \
&&      cp "/tmp/relay-dev-php8.3-debian-$RELAY+libssl3/relay-pkg.so" $(php-config --extension-dir)/relay.so \
&&      sed -i "s/00000000-0000-0000-0000-000000000000/$(cat /proc/sys/kernel/random/uuid)/" $(php-config --extension-dir)/relay.so \
&&      chmod 755 $(php-config --extension-dir)/relay.so \
&&      touch /var/www/html/config/preload.php \
&&      apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false build-essential autoconf dpkg-dev re2c bison libxml2-dev libssl-dev libsqlite3-dev xz-utils libargon2-dev libgcc-12-dev \
        libnghttp3-dev libonig-dev libreadline-dev libsodium-dev zlib1g-dev libbz2-dev libgmp-dev libedit-dev libtidy-dev libnghttp2-dev librtmp-dev libgsasl-dev libpsl-dev libzstd-dev libcrypt-dev \
        libbrotli-dev libjpeg62-turbo-dev libpng-dev libwebp-dev libfreetype-dev liblz4-dev liblzf-dev pkgconf make icu-devtools libbsd-dev libc-dev-bin libc6-dev libgssglue-dev libhiredis-dev libicu-dev \
        libidn-dev libidn11-dev libidn2-dev libmd-dev libncurses-dev libnsl-dev libntlm0-dev libp11-kit-dev libstdc++-12-dev libtasn1-6-dev libtirpc-dev linux-libc-dev g++ gcc \
&&      apt-get autoremove -y --purge \
&&      rm -rf \
            ~/.pearrc \
            /home/vairogs/installer \
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
COPY    php/exts/relay.ini /usr/local/etc/php/conf.d/docker-php-ext-relay.ini

RUN     \
        set -eux \
&&      chmod 644 /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini \
&&      echo zlib.output_compression = 4096 >> /usr/local/etc/php/conf.d/docker-php-ext-zlib.ini \
&&      echo zlib.output_compression_level = 9 >> /usr/local/etc/php/conf.d/docker-php-ext-zlib.ini \
&&      git config --global --add safe.directory "*" \
&&      chown -R vairogs:vairogs /home/vairogs

WORKDIR /var/www/html

USER    vairogs

CMD     ["sh", "-c", "php-fpm && /bin/bash"]

FROM    scratch

COPY    --from=builder / / 

SHELL   ["/bin/bash", "-o", "pipefail", "-c"]

ENV     PHP_VERSION 8.3.0-dev
ENV     PHP_INI_DIR /usr/local/etc/php
ENV     PHP_CFLAGS "-fstack-protector-strong -fpic -fpie -O2 -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64"
ENV     PHP_CPPFLAGS "$PHP_CFLAGS"
ENV     PHP_LDFLAGS "-Wl,-O1 -pie"
LABEL   maintainer="support+docker@vairogs.com"
ENV     container=docker
ENV     DEBIAN_FRONTEND=noninteractive

STOPSIGNAL SIGQUIT

WORKDIR /var/www/html

USER    vairogs

EXPOSE  9000

CMD     ["sh", "-c", "php-fpm && /bin/bash"]
