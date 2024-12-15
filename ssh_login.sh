#!/bin/bash

# config files 
NTFY_CONFIG_FILE="/home/kcn/script/ntfy.config"                 # change to your path
ALLOWED_IP_CONFIG_FILE="/home/kcn/script/allowed_ip.config"     # change to your path


source "$NTFY_CONFIG_FILE"
source "$ALLOWED_IP_CONFIG_FILE"

LOG_FILE="/var/log/auth.log"  


# read logs
tail -n 0 -F "$LOG_FILE" | while read line; do
    # check if login failed
    if echo "$line" | grep -q "sshd.*Failed"; then

        IP=$(echo "$line" | grep -oP 'from \K[\d.]+' | tr -d '[:space:]')

        # is allowed
        if [[ "$IP" != "$ALLOWED_IP" && -n "$IP" ]]; then
            # send ntfy
            curl -u $NTFY_LOGIN:$NTFY_PASSWORD -d "Connection Failed from IP: $IP" \
                 -H "Title: 💻 SSH Login Attempt" \
                 -H "Priority: high" \
                 -H "Tags: stop_sign, warning" \
                 $NTFY_URL

        fi
    fi

    if echo "$line" | grep "Accepted"; then
        # get ip address
        IP=$(echo "$line" | grep -oP 'from \K[\d.]+' | tr -d '[:space:]')

        # check is allowed
        if [[ "$IP" != "$ALLOWED_IP" && -n "$IP" ]]; then
            # send ntfy
            curl -u $NTFY_LOGIN:$NTFY_PASSWORD -d "Connection Accepted from IP: $IP" \
                 -H "Title: 💻 SSH Login Attempt" \
                 -H "Priority: high" \
                 -H "Tags: checkmark" \
                 $NTFY_URL

        fi
    fi
done