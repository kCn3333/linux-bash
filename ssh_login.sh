#!/bin/bash

# Definiuj dozwolone IP
ALLOWED_IP="192.168.0.59"  # Zmień na swoje dozwolone IP
LOG_FILE="/var/log/auth.log"  # Zmienna dla pliku logów


# Monitoruj logi w czasie rzeczywistym
tail -n 0 -F "$LOG_FILE" | while read line; do
    # Sprawdzamy tylko linie zawierające nieudane logowanie
    if echo "$line" | grep -q "sshd.*Failed"; then

        IP=$(echo "$line" | grep -oP 'from \K[\d.]+' | tr -d '[:space:]')

        # Porównaj z ostatnim zapisanym IP
        if [[ "$IP" != "$ALLOWED_IP" && -n "$IP" ]]; then
            # Wyślij powiadomienie ntfy
            curl -u kCn:03orzeszki! -d "Connection Failed from IP: $IP" \
                 -H "Title: 💻 SSH Login Attempt" \
                 -H "Priority: high" \
                 -H "Tags: stop_sign, warning" \
                 https://ntfy.kcn333.pl/serwer-h3XUKkNRywZZONAO

        fi
    fi

    if echo "$line" | grep "Accepted"; then
        # Wyciągnij adres IP
        IP=$(echo "$line" | grep -oP 'from \K[\d.]+' | tr -d '[:space:]')

        # Porównaj z ostatnim zapisanym IP
        if [[ "$IP" != "$ALLOWED_IP" && -n "$IP" ]]; then
            # Wyślij powiadomienie ntfy
            curl -u kCn:03orzeszki! -d "Connection Accepted from IP: $IP" \
                 -H "Title: 💻 SSH Login Attempt" \
                 -H "Priority: high" \
                 -H "Tags: white_check_mark" \
                 https://ntfy.kcn333.pl/serwer-h3XUKkNRywZZONAO  

        fi
    fi
done