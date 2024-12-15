#!/bin/bash

# Funkcja sprawdzająca temperaturę procesora
check_temperature() {
    # Pobierz temperaturę procesora z wyniku sensors
    temp=$(sensors | grep 'Package id 0:' | awk '{print $4}' | sed 's/+//' | sed 's/°C//')
    echo "Current temp: ${temp}°C" 
    # Sprawdź, czy temperatura jest większa niż 60°C
    if (( $(echo "$temp > 72" | bc -l) )); then
        # Wyślij powiadomienie ntfy
        curl -u kCn:03orzeszki! -d "Warning: CPU temperature is too high! Current temp: ${temp}°C" \
        -H "Title:🔥🔥🔥 Its'too hoot 🔥🔥🔥" \
        -H "Priority: high" \
        -H "Tags: fire_extinguisher" \
        https://ntfy.kcn333.pl/serwer-h3XUKkNRywZZONAO
    fi
}

# Monitoruj temperaturę w pętli
while true; do
    check_temperature
    # Odczekaj 60 sekund przed kolejnym sprawdzeniem
    sleep 60
done