#!/bin/sh

# Set REPLACE_ME_* strings in telegraf.conf with passwords from secrets file.
# https://github.com/Robpol86/influxdb/blob/master/nmc/entrypoint_secrets.sh
# Save as (chmod +x): /entrypoint_secrets.sh

set -e  # Exit script if a command fails.
set -u  # Treat unset variables as errors and exit immediately.
set -o pipefail  # Exit script if pipes fail instead of just the last program.

IN_FILE=/etc/telegraf/telegraf.conf.template
OUT_FILE=/etc/telegraf/telegraf.conf
SECRETS=/run/secrets/nmc

# Set passwords.
if [ -f "$SECRETS" ]; then
    sed \
        -e "s/REPLACE_ME_DB/$(sed -n 1p ${SECRETS})/g" \
        -e "s/REPLACE_ME_SNMP/$(sed -n 2p ${SECRETS})/g" \
        ${IN_FILE} > ${OUT_FILE}
else
    echo "WARNING: $SECRETS does not exist, skipping."
fi

# Run entrypoint.sh.
set +euo pipefail
source /entrypoint.sh
