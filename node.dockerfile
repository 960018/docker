ARG     VERSION

FROM    node:${VERSION}-bookworm-slim AS builder

ENV     container=docker
ENV     DEBIAN_FRONTEND=noninteractive

SHELL   ["/bin/bash", "-o", "pipefail", "-c"]

COPY    global/01_nodoc  /etc/dpkg/dpkg.cfg.d/01_nodoc
COPY    global/02_nocache /etc/apt/apt.conf.d/02_nocache
COPY    global/compress  /etc/initramfs-tools/conf.d/compress
COPY    global/modules   /etc/initramfs-tools/conf.d/modules

USER    root

RUN     \
        set -eux \
&&      usermod -l vairogs node \
&&      usermod -d /home/vairogs -m vairogs \
&&      groupmod -n vairogs node \
&&      mkdir --parents /home/vairogs \
&&      echo >> /home/vairogs/.bashrc \
&&      echo 'alias ll="ls -lahs"' >> /home/vairogs/.bashrc \
&&      echo 'alias ll="ls -lahs"' >> /root/.bashrc \
&&      apt-get update \
&&      apt-get upgrade -y \
&&      apt-get install -y --no-install-recommends procps curl ca-certificates unzip \
&&      update-ca-certificates \
&&      apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
&&      apt-get autoremove -y --purge \
&&      rm -rf \
            /etc/nginx/conf.d/* \
            /home/vairogs/*.deb \
            /*.deb \
            /tmp/* \
            /usr/share/man \
            /usr/share/doc \
            /usr/local/share/man \
            /var/lib/apt/lists/* \
            /usr/lib/python3.11/__pycache__ \
            /home/node \
            /root/.node-gyp \
            /usr/local/lib/node_modules/npm/man \
            /usr/local/lib/node_modules/npm/docs \
            /usr/local/lib/node_modules/npm/html \
            /root/.npm \
            /root/.cache \
&&      usermod -a -G dialout vairogs \
&&      npm i -g npm@next-10

USER    vairogs

FROM    ghcr.io/960018/scratch:latest

COPY    --from=builder / /

ARG     VERSION

ENV     NODE_VERSION=${VERSION}
ENV     YARN_VERSION=1.22.19
ENV     NODE_COMPILE_CACHE=/home/vairogs/.node_cache

ENTRYPOINT ["docker-entrypoint.sh"]

CMD     ["node"]
