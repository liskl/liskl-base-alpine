FROM scratch as base
LABEL maintainer="Loren Lisk <loren.lisk@liskl.com>"

FROM base AS base-amd64
ADD files/alpine-minirootfs-3.16.2-x86_64.tar.gz /

FROM base AS base-arm64
ADD files/alpine-minirootfs-3.16.2-armhf.tar.gz /

# Alpine edge rootFS as of 2016-11-01

ARG TARGETARCH
FROM base-$TARGETARCH AS release
RUN env

CMD [ "/bin/sh" ]