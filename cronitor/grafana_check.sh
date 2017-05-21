#!/bin/sh

# Ping Cronitor if the local Grafana is reachable.
# https://github.com/Robpol86/influxdb/blob/master/cronitor/grafana_check.sh
# Save as (chmod +x): /etc/periodic/5min/grafana_check

set -e  # Exit script if a command fails.
set -u  # Treat unset variables as errors and exit immediately.
set -o pipefail  # Exit script if pipes fail instead of just the last program.

alias curl='curl -fsS -o /dev/null -m 10'
SECRETS=/run/secrets/cronitor

# Get ID in unique ping URL.
ID=$(sed -n 1p ${SECRETS} |egrep -om1 '^\w+' || true)
if [ -z "$ID" ]; then
    echo "ERROR: No Cronitor URL ID found (first line in $SECRETS)." >&2
    exit 1
fi

# Get auth token.
TOKEN=$(sed -n 2p /run/secrets/cronitor |egrep -om1 '^\w+' || true)
if [ -z "$TOKEN" ]; then
    echo "ERROR: No Cronitor auth token found (second line in $SECRETS)." >&2
    exit 1
fi

# Run.
curl https://cronitor.link/${ID}/run?auth_key=${TOKEN}
if curl http://grafana:3000/api/health; then
    curl https://cronitor.link/${ID}/complete?auth_key=${TOKEN}
else
    curl https://cronitor.link/${ID}/fail?auth_key=${TOKEN}
fi
