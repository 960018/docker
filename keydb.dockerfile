FROM    eqalpha/keydb:latest AS builder

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
        rm -rf \
            /etc/keydb/keydb.conf \
            /etc/keydb/redis.conf \
&&      usermod -l vairogs keydb \
&&      usermod -d /home/vairogs -m vairogs \
&&      groupmod -n vairogs keydb \
&&      usermod -u 1000 vairogs \
&&      groupmod -g 1000 vairogs \
&&      mkdir --parents /home/vairogs \
&&      echo >> /home/vairogs/.bashrc \
&&      echo 'alias ll="ls -lahs"' >> /home/vairogs/.bashrc \
&&      echo 'alias ll="ls -lahs"' >> /root/.bashrc \
&&      apt-get update \
&&      apt-get upgrade -y \
&&      apt-get install -y --no-install-recommends bash procps \
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
&&      chown -R vairogs:vairogs /data \
&&      chown -R vairogs:vairogs /flash \
&&      usermod -a -G dialout vairogs

COPY    ./keydb/keydb.conf /etc/keydb/keydb.conf

RUN     \
        set -eux \
&&      ln -sf /etc/keydb/keydb.conf /etc/keydb/redis.conf

USER    vairogs

FROM    ghcr.io/960018/scratch:latest

COPY    --from=builder / /

EXPOSE  6379

ENTRYPOINT ["docker-entrypoint.sh"]
CMD     ["keydb-server", "/etc/keydb/keydb.conf"]
