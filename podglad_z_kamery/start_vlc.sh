#!/bin/bash

# Adres strumienia RTSP
STREAM_URL="rtsp://admin:69DupaDupa@192.168.0.64:554/Streaming/Channels/101"

# Uruchomienie VLC w tle z podanym strumieniem
vlc "$STREAM_URL" --quiet &

# Wyświetlenie komunikatu o uruchomieniu
echo "VLC uruchomione w tle z adresem strumienia: $STREAM_URL"
