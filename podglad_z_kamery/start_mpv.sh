#!/bin/bash

# Strumień RTSP
RTSP_URL="rtsp://admin:69DupaDupa@192.168.0.64:554/Streaming/Channels/101"

# Uruchomienie mpv w tle
mpv "$RTSP_URL"
#nohup mpv "$RTSP_URL" > /dev/null 2>&1
echo "Stream RTSP uruchomiony w tle."
