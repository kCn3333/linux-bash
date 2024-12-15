#!/bin/bash

NTFY_CONFIG_FILE="/home/kcn/script/ntfy.config"
source $NTFY_CONFIG_FILE


check_temperature() {
    # get temp from sensors
    temp=$(sensors | grep 'Package id 0:' | awk '{print $4}' | sed 's/+//' | sed 's/°C//')
    echo "Current temp: ${temp}°C" 
    # is higher than 72C
    if (( $(echo "$temp > 72" | bc -l) )); then
        # send ntfy
        curl -u $NTFY_LOGIN:$NTFY_PASSWORD -d "Warning: CPU temperature is too high! Current temp: ${temp}°C" \
        -H "Title:🔥🔥🔥 Its'too hoot 🔥🔥🔥" \
        -H "Priority: high" \
        -H "Tags: fire_extinguisher" \
        $NTFY_URL
    fi
}


while true; do
    check_temperature
    # wait 60sec
    sleep 60
done