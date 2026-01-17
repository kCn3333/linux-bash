#!/bin/bash

i3status -c ~/.config/i3status/config | while :
do
    read line
    # bluetooth connection status
    if bluetoothctl info E0:08:71:BB:91:C3 2>/dev/null | grep -q "Connected: yes"; then
        BT=" On"
    else
        BT=" Off"
    fi
    
    # 
    echo "$line | 󰋋$BT "
done
