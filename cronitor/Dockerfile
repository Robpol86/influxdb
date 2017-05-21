FROM alpine:latest
MAINTAINER Robpol86 <robpol86@gmail.com>

RUN apk add --no-cache curl && \
    mkdir mkdir /etc/periodic/5min && \
    echo -e "*/5\t*\t*\t*\t*\trun-parts /etc/periodic/5min" >> /var/spool/cron/crontabs/root

COPY grafana_check.sh /etc/periodic/5min/grafana_check

ENTRYPOINT ["crond", "-l2", "-f"]
