FROM alpine:latest
MAINTAINER Robpol86 <robpol86@gmail.com>

RUN apk add --no-cache openssh-client socat supervisor tor
VOLUME /root/copy

COPY ssh_config /etc/ssh/ssh_config
COPY supervisord.conf /etc/supervisord.conf

ENTRYPOINT ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
