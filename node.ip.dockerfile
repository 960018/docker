ARG OS

FROM    ghcr.io/960018/node:21-${OS} as builder

WORKDIR /app

COPY    node/ip/index.js node/ip/package.json /app/

USER    root

RUN     \
        set -eux \
&&      /home/vairogs/.bun/bin/bun install \
&&      chown -R vairogs:vairogs /app

ARG OS

FROM    ghcr.io/960018/node:21-${OS}

WORKDIR /app

COPY    --from=builder /app /app

ENV     HTTP_PORT=8080

EXPOSE  ${HTTP_PORT}

USER    vairogs

CMD     ["/home/vairogs/.bun/bin/bun", "start"]
