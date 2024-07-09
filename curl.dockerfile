ARG     ARCH

FROM    debian:sid-slim AS builder

LABEL   maintainer="support+docker@vairogs.com"
ENV     container=docker
ENV     DEBIAN_FRONTEND=noninteractive

SHELL   ["/bin/bash", "-o", "pipefail", "-c"]

COPY    global/01_nodoc  /etc/dpkg/dpkg.cfg.d/01_nodoc
COPY    global/02_nocache /etc/apt/apt.conf.d/02_nocache
COPY    global/compress  /etc/initramfs-tools/conf.d/compress
COPY    global/modules   /etc/initramfs-tools/conf.d/modules

COPY    global/wait-for-it.sh /usr/local/bin/wait-for-it

USER    root

RUN     \
        set -eux \
&&      groupadd --system --gid 1000 vairogs \
&&      useradd --system --uid 1000 -g vairogs --shell /bin/bash --home /home/vairogs vairogs \
&&      passwd -d vairogs \
&&      usermod -a -G dialout vairogs

WORKDIR /home/vairogs

RUN     \
        set -eux \
&&      apt-get update \
&&      apt-get upgrade -y \
&&      apt-get install -y --no-install-recommends vim-tiny tzdata bash ca-certificates procps iputils-ping telnet unzip apt-utils pkg-config \
&&      echo 'alias ll="ls -lahs"' >> /home/vairogs/.bashrc \
&&      echo 'alias ll="ls -lahs"' >> /root/.bashrc \
&&      chown vairogs:vairogs /usr/local/bin/wait-for-it \
&&      chmod +x /usr/local/bin/wait-for-it \
&&      ln -sf /usr/bin/vi /usr/bin/vim

WORKDIR /home/vairogs

COPY    curl/src/ /home/vairogs/curl
COPY    curl/clone/wolfsslsrc/ /home/vairogs/wolfssl
COPY    curl/clone/ngtcp2src/ /home/vairogs/ngtcp2
COPY    curl/clone/nghttp3src/ /home/vairogs/nghttp3

RUN     \
        set -eux \
&&      apt-get update \
&&      apt-get upgrade -y \
&&      apt-get install -y --no-install-recommends make automake autoconf libtool ca-certificates gcc g++ libbrotli1 libbrotli-dev zstd libzstd-dev librtmp-dev librtmp1 rtmpdump pkg-config \
        libgsasl-dev libgsasl18 libpsl-dev perl libnghttp2-dev nghttp2 libssl-dev libssl3t64 libpsl5t64 \
&&      cd  nghttp3 \
&&      autoreconf -fi \
&&      ./configure --prefix=/usr/local --enable-lib-only \
&&      make \
&&      make install \
&&      cd ../wolfssl \
&&      autoreconf -fi \
&&      ./configure --enable-session-ticket --enable-earlydata --enable-psk --enable-altcertchains --disable-examples \
            --enable-dtls --enable-sctp --enable-opensslextra --enable-opensslall --enable-sniffer --enable-sha512 --enable-ed25519 --enable-rsapss --enable-base64encode --enable-tlsx \
            --enable-scrypt --disable-crypttests --enable-fastmath --enable-harden --enable-quic --enable-all --enable-experimental \
&&      make \
&&      make install \
&&      cd ../ngtcp2 \
&&      autoreconf -fi \
&&      ./configure LDFLAGS="-Wl,-rpath,/usr/local/lib" --prefix=/usr/local --with-wolfssl --enable-lib-only \
&&      make \
&&      make install \
&&      cd ../curl \
&&      autoreconf -fi \
&&      ./configure CFLAGS='-fstack-protector-strong -fpic -fpie -O3 -ftree-vectorize -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64 -march=native -mtune=native' --prefix=/usr/local \
            --with-wolfssl --with-zlib --with-brotli --enable-ipv6 --with-libidn2 --enable-sspi --with-librtmp --with-ngtcp2 --with-nghttp3 --with-nghttp2 --enable-websockets --with-zstd --disable-manual --disable-docs \
            --enable-ech \
&&      make \
&&      make install \
&&      apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false libbrotli-dev git cmake make automake autoconf libtool gcc g++ libzstd-dev libssl-dev librtmp-dev krb5-multidev libcrypt-dev libnsl-dev libtirpc-dev linux-libc-dev comerr-dev perl libnghttp3-dev \
            libnghttp2-dev libgsasl-dev libgssglue-dev libidn-dev libidn11-dev libntlm0-dev libpsl-dev curl libcurl4 libgss-dev \
&&      apt-get autoremove -y --purge \
&&      ldconfig \
&&      sed -i 's/Requires.private/Requires/' /usr/local/lib/pkgconfig/libcurl.pc \
&&      sed -i '0,/^Requires:.*$/s///' /usr/local/lib/pkgconfig/libcurl.pc \
&&      sed -i '/^Libs:/ { N; s/\nLibs\.private: / /; }' /usr/local/lib/pkgconfig/libcurl.pc \
&&      rm -rf \
            /home/vairogs/curl \
            /home/vairogs/wolfssl \
            /home/vairogs/ngtcp2 \
            /home/vairogs/nghttp3 \
            /home/vairogs/*.deb \
            /*.deb \
            /tmp/* \
            /var/cache/* \
            /usr/share/man \
            /usr/share/doc \
            /usr/local/share/man \
            /var/lib/apt/lists/* \
            /usr/lib/python3.11/__pycache__

USER    vairogs

CMD     ["/bin/bash"]

FROM    ghcr.io/960018/scratch:${ARCH}

COPY    --from=builder / /

WORKDIR /home/vairogs

CMD     ["/bin/bash"]
