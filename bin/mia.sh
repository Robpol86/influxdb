#!/bin/bash

# Print user's last log if they haven't logged in n number of minutes.
# Print nothing and exit 0 if user is within time limit.
# https://github.com/Robpol86/influxdb/blob/master/bin/mia.sh
# Save as (chmod +x): /usr/local/bin/mia

set -e  # Exit script if a command fails.
set -u  # Treat unset variables as errors and exit immediately.
set -o pipefail  # Exit script if pipes fail instead of just the last program.

# Verify arguments.
if [ $# -eq 0 ]; then
    echo "Must specify a user name to look up."
    exit 2
elif [ $# -eq 1 ]; then
    echo "Must specify number of minutes to check against."
    exit 2
elif [[ ! $2 =~ ^[0-9]+$ ]]; then
    echo "Second argument must be an integer."
    exit 2
fi
id -u -- $1 > /dev/null  # Exits if user doesn't exist.

# Get logout time.
outtime=$(last -RF -- $1 |grep -v crash |head -1 |cut -c50-74 |xargs)
if [ "$outtime" == "still logged in" ]; then
    exit 0
fi

# Get time difference.
difference=$(( $(date +%s) - $(date -d "$outtime" +%s) ))
if [ ${difference} -lt $(( $2 * 60 )) ]; then
    exit 0
fi

# User last logged in over threshold.
last -RF -- $1
exit 1
