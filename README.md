# SSH Login Attempt Monitoring and Notification

This script is designed to monitor failed and successful SSH login attempts on your server and notify you of any login attempts from unauthorized IPs. It sends notifications via **ntfy** when an SSH login is attempted from an IP address that is not on your allowed list.

## Requirements

Before using this script, you need to have the following:

- **ntfy**: A notification service used for sending messages.
- **curl**: For making HTTP requests.
- **systemd**: To run the script as a service

## Config Files

**`ntfy.config`**: Contains your **ntfy** credentials (URL, username, password).
```
NTFY_USERNAME="your-username"
NTFY_PASSWORD="your-password"
NTFY_URL="https://ntfy.domain.com"
```
**`allowed_ip.config`**: Contains a list of allowed IP addresses for SSH logins.
```
ALLOWED_IP="192.168.3.33"
```

## Setting Up as a Systemd Service

Create a new systemd unit file:
```
sudo nano /etc/systemd/system/ssh_monitor.service
```
Add the following contents to the file:
```
[Unit]
Description=Monitor SSH login attempts
After=network.target

[Service]
ExecStart=/path/to/ssh_login.sh
Restart=always
User=your-username

[Install]
WantedBy=multi-user.target
```
Enable and start the service:
```
sudo systemctl daemon-reload
sudo systemctl enable ssh_monitor.service
sudo systemctl start ssh_monitor.service
```
Check the status of the service:
```
sudo systemctl status ssh_monitor.service
```

# Temperature Monitor Script

This script monitors the temperature of your system (or specific hardware components like CPU) and sends notifications if the temperature exceeds a predefined threshold. You can configure the threshold, notification settings, and more.

## Requirements

Before using this script, you need to ensure the following:

- **lm-sensors**: This package is used to read hardware sensor data (e.g., CPU temperature).
- **ntfy**: Used for sending notifications.
- **curl**: For sending HTTP requests to ntfy.

## Config Files

**`ntfy.config`**: Contains your **ntfy** credentials (URL, username, password).
```
NTFY_USERNAME="your-username"
NTFY_PASSWORD="your-password"
NTFY_URL="https://ntfy.domain.com"
```

## Setting Up as a Systemd Service

Create a new systemd unit file:
```
sudo nano /etc/systemd/system/temp_monitor.service
```
Add the following contents to the file:
```
[Unit]
Description=Monitor System Temperature and Send Notifications
After=network.target

[Service]
ExecStart=/path/to/monitor_temp.sh
Restart=always
User=your-username

[Install]
WantedBy=multi-user.target
```
Enable and start the service:
```
sudo systemctl daemon-reload
sudo systemctl enable temp_monitor.service
sudo systemctl start temp_monitor.service
```
Check the status of the service:
```
sudo systemctl status temp_monitor.service
```
```