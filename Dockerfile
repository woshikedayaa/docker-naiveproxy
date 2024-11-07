FROM debian:bookworm

ARG NAIVEPROXY_BIN
ARG NAIVEPROXY_VERSION

ENV NAIVEPROXY_VERSION=${NAIVEPROXY_VERSION}
ENV PROXY=""
ENV SCHEME="socks"
ENV LISTEN="0.0.0.0"
ENV PORT="1080"
ENV CONCURRENCY="1"

COPY ${NAIVEPROXY_BIN} /usr/bin/naive
COPY entry.sh /entry.sh

RUN set -ex \
    && apt update \
    && apt install ca-certificates -y \
    && apt clean \
    && apt autoremove \
    && chmod +x /usr/bin/naive /entry.sh;

EXPOSE 1080
VOLUME /etc/naive

ENTRYPOINT [ "/entry.sh" ]
