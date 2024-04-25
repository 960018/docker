ARG ARCH

FROM    ghcr.io/960018/node:21-${ARCH} AS builder

ARG     SCRIPT

WORKDIR /app

COPY    node/${SCRIPT}/index.js node/${SCRIPT}/package.json /app/

USER    root

RUN     \
        set -eux \
&&      chown -R vairogs:vairogs /app

USER    vairogs

ARG ARCH

FROM    ghcr.io/960018/node:21-${ARCH}

WORKDIR /app

COPY    --from=builder /app /app

ENV     HTTP_PORT=8080

EXPOSE  ${HTTP_PORT}

USER    vairogs

CMD     ["yarn", "start"]
