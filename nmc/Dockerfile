FROM telegraf:alpine
MAINTAINER Robpol86 <robpol86@gmail.com>

RUN apk add --no-cache net-snmp-tools && \
    wget ftp://ftp.apc.com/apc/public/software/pnetmib/mib/421/powernet421.mib -O /usr/share/snmp/mibs/PowerNet-MIB.txt

COPY entrypoint_secrets.sh /
COPY telegraf.conf /etc/telegraf/telegraf.conf.template

ENTRYPOINT ["/entrypoint_secrets.sh"]
CMD ["telegraf"]
