FROM scratch as base
LABEL maintainer="Loren Lisk <loren.lisk@liskl.com>"

FROM base AS base-amd64
ADD files/alpine-minirootfs-3.16.2-amd64.tar.gz /

FROM base AS base-arm32v7
ADD files/alpine-minirootfs-3.16.2-arm32v7.tar.gz /

FROM base AS base-arm64v8
ADD files/alpine-minirootfs-3.16.2-arm64v8.tar.gz /

ARG TARGETARCH
FROM base-$TARGETARCH AS release

RUN apk add --no-cache bash

CMD [ "/usr/bin/bash" ]