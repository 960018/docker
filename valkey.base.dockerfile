#
# Copy from https://github.com/valkey-io/valkey-container/ with small changes:
# 1. bookworm -> sid
# 2. chmod +x entrypoint
# 3. use full entrypoint path
#

FROM debian:sid-slim

# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
RUN set -eux; \
    groupadd -r -g 999 valkey; \
    useradd -r -g valkey -u 999 valkey

# runtime dependencies
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
# add tzdata explicitly for https://github.com/docker-library/valkey/issues/138 (see also https://bugs.debian.org/837060 and related)
        tzdata \
    ; \
    rm -rf /var/lib/apt/lists/*

# grab gosu for easy step-down from root
# https://github.com/tianon/gosu/releases
ENV GOSU_VERSION 1.17
RUN set -eux; \
    savedAptMark="$(apt-mark showmanual)"; \
    apt-get update; \
    apt-get install -y --no-install-recommends ca-certificates gnupg wget; \
    rm -rf /var/lib/apt/lists/*; \
    arch="$(dpkg --print-architecture | awk -F- '{ print $NF }')"; \
    case "$arch" in \
        'amd64') url='https://github.com/tianon/gosu/releases/download/1.17/gosu-amd64'; sha256='bbc4136d03ab138b1ad66fa4fc051bafc6cc7ffae632b069a53657279a450de3' ;; \
        'arm64') url='https://github.com/tianon/gosu/releases/download/1.17/gosu-arm64'; sha256='c3805a85d17f4454c23d7059bcb97e1ec1af272b90126e79ed002342de08389b' ;; \
        'armel') url='https://github.com/tianon/gosu/releases/download/1.17/gosu-armel'; sha256='f9969910fa141140438c998cfa02f603bf213b11afd466dcde8fa940e700945d' ;; \
        'i386') url='https://github.com/tianon/gosu/releases/download/1.17/gosu-i386'; sha256='087dbb8fe479537e64f9c86fa49ff3b41dee1cbd28739a19aaef83dc8186b1ca' ;; \
        'mips64el') url='https://github.com/tianon/gosu/releases/download/1.17/gosu-mips64el'; sha256='87140029d792595e660be0015341dfa1c02d1181459ae40df9f093e471d75b70' ;; \
        'ppc64el') url='https://github.com/tianon/gosu/releases/download/1.17/gosu-ppc64el'; sha256='1891acdcfa70046818ab6ed3c52b9d42fa10fbb7b340eb429c8c7849691dbd76' ;; \
        'riscv64') url='https://github.com/tianon/gosu/releases/download/1.17/gosu-riscv64'; sha256='38a6444b57adce135c42d5a3689f616fc7803ddc7a07ff6f946f2ebc67a26ba6' ;; \
        's390x') url='https://github.com/tianon/gosu/releases/download/1.17/gosu-s390x'; sha256='69873bab588192f760547ca1f75b27cfcf106e9f7403fee6fd0600bc914979d0' ;; \
        'armhf') url='https://github.com/tianon/gosu/releases/download/1.17/gosu-armhf'; sha256='e5866286277ff2a2159fb9196fea13e0a59d3f1091ea46ddb985160b94b6841b' ;; \
        *) echo >&2 "error: unsupported gosu architecture: '$arch'"; exit 1 ;; \
    esac; \
    wget -O /usr/local/bin/gosu.asc "$url.asc"; \
    wget -O /usr/local/bin/gosu "$url"; \
    echo "$sha256 */usr/local/bin/gosu" | sha256sum -c -; \
    export GNUPGHOME="$(mktemp -d)"; \
    gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4; \
    gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu; \
    gpgconf --kill all; \
    rm -rf "$GNUPGHOME" /usr/local/bin/gosu.asc; \
    apt-mark auto '.*' > /dev/null; \
    [ -z "$savedAptMark" ] || apt-mark manual $savedAptMark > /dev/null; \
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
    chmod +x /usr/local/bin/gosu; \
    gosu --version; \
    gosu nobody true

ENV VALKEY_VERSION unstable
ENV VALKEY_DOWNLOAD_URL https://github.com/valkey-io/valkey/archive/unstable.tar.gz
ENV VALKEY_DOWNLOAD_SHA 0000000000000000000000000000000000000000000000000000000000000000

RUN set -eux; \
    \
    savedAptMark="$(apt-mark showmanual)"; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        wget \
        \
        dpkg-dev \
        gcc \
        libc6-dev \
        libssl-dev \
        make \
    ; \
    rm -rf /var/lib/apt/lists/*; \
    \
    wget -O valkey.tar.gz "$VALKEY_DOWNLOAD_URL"; \
            echo "Unstable Valkey version, do not compare SHA256SUM" ;\
        \
    mkdir -p /usr/src/valkey; \
    tar -xzf valkey.tar.gz -C /usr/src/valkey --strip-components=1; \
    rm valkey.tar.gz; \
    \
# disable Valkey protected mode [1] as it is unnecessary in context of Docker
# (ports are not automatically exposed when running inside Docker, but rather explicitly by specifying -p / -P)
    grep -E '^ *createBoolConfig[(]"protected-mode",.*, *1 *,.*[)],$' /usr/src/valkey/src/config.c; \
    sed -ri 's!^( *createBoolConfig[(]"protected-mode",.*, *)1( *,.*[)],)$!\10\2!' /usr/src/valkey/src/config.c; \
    grep -E '^ *createBoolConfig[(]"protected-mode",.*, *0 *,.*[)],$' /usr/src/valkey/src/config.c; \
# for future reference, we modify this directly in the source instead of just supplying a default configuration flag because apparently "if you specify any argument to valkey-server, [it assumes] you are going to specify everything"
# (more exactly, this makes sure the default behavior of "save on SIGTERM" stays functional by default)
    \
# https://github.com/jemalloc/jemalloc/issues/467 -- we need to patch the "./configure" for the bundled jemalloc to match how Debian compiles, for compatibility
# (also, we do cross-builds, so we need to embed the appropriate "--build=xxx" values to that "./configure" invocation)
    gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)"; \
    extraJemallocConfigureFlags="--build=$gnuArch"; \
# https://salsa.debian.org/debian/jemalloc/-/blob/c0a88c37a551be7d12e4863435365c9a6a51525f/debian/rules#L8-23
    dpkgArch="$(dpkg --print-architecture)"; \
    case "${dpkgArch##*-}" in \
        amd64 | i386 | x32) extraJemallocConfigureFlags="$extraJemallocConfigureFlags --with-lg-page=12" ;; \
        *) extraJemallocConfigureFlags="$extraJemallocConfigureFlags --with-lg-page=16" ;; \
    esac; \
    extraJemallocConfigureFlags="$extraJemallocConfigureFlags --with-lg-hugepage=21"; \
    grep -F 'cd jemalloc && ./configure ' /usr/src/valkey/deps/Makefile; \
    sed -ri 's!cd jemalloc && ./configure !&'"$extraJemallocConfigureFlags"' !' /usr/src/valkey/deps/Makefile; \
    grep -F "cd jemalloc && ./configure $extraJemallocConfigureFlags " /usr/src/valkey/deps/Makefile; \
    \
    export BUILD_TLS=yes; \
    make -C /usr/src/valkey -j "$(nproc)" all; \
    make -C /usr/src/valkey install; \
    \
    serverMd5="$(md5sum /usr/local/bin/valkey-server | cut -d' ' -f1)"; export serverMd5; \
    find /usr/local/bin/valkey* -maxdepth 0 \
        -type f -not -name valkey-server \
        -exec sh -eux -c ' \
            md5="$(md5sum "$1" | cut -d" " -f1)"; \
            test "$md5" = "$serverMd5"; \
        ' -- '{}' ';' \
        -exec ln -svfT 'valkey-server' '{}' ';' \
    ; \
    \
    rm -r /usr/src/valkey; \
    \
    apt-mark auto '.*' > /dev/null; \
    [ -z "$savedAptMark" ] || apt-mark manual $savedAptMark > /dev/null; \
    find /usr/local -type f -executable -exec ldd '{}' ';' \
        | awk '/=>/ { so = $(NF-1); if (index(so, "/usr/local/") == 1) { next }; gsub("^/(usr/)?", "", so); print so }' \
        | sort -u \
        | xargs -r dpkg-query --search \
        | cut -d: -f1 \
        | sort -u \
        | xargs -r apt-mark manual \
    ; \
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
    \
    valkey-cli --version; \
    valkey-server --version; \
    \
    echo '{"spdxVersion":"SPDX-2.3","SPDXID":"SPDXRef-DOCUMENT","name":"valkey-server-sbom","packages":[{"name":"valkey-server","versionInfo":"unstable","SPDXID":"SPDXRef-Package--valkey-server","externalRefs":[{"referenceCategory":"PACKAGE-MANAGER","referenceType":"purl","referenceLocator":"pkg:generic/valkey-server@unstable?os_name=debian&os_version=bookworm"}],"licenseDeclared":"BSD-3-Clause"}]}' > /usr/local/valkey.spdx.json

RUN mkdir /data && chown valkey:valkey /data
VOLUME /data
WORKDIR /data

COPY valkey/docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

EXPOSE 6379
CMD ["valkey-server"]
