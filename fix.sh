#!/bin/bash

# Variables
BOT_SCRIPT_URL="https://raw.githubusercontent.com/odflix/rsa/main/setup_telegram_bot.sh"
VENV_DIR="/opt/telegram_bot_venv"
BOT_SCRIPT_PATH="/opt/telegram_bot.py"
SERVICE_FILE="/etc/systemd/system/telegram_bot.service"
NGROK_CMD="ngrok tcp 192.168.1.212:3389"
TELEGRAM_BOT_TOKEN="5614449969:AAHyTMl-vt1jLoQ4uKifU0F656NHRTFwYSE"
NGROK_API_KEY="2kBcjD0HAI3PMzEtmHP2XNHIzz3_5w537UjyRkqFF6CGGAXg9"
ALLOWED_USERS="658490863,725718328"

# Update and install dependencies
echo "Updating system..."
apt-get update -y
apt-get install -y python3-pip python3-venv curl

# Create virtual environment
echo "Creating virtual environment..."
python3 -m venv $VENV_DIR

# Activate virtual environment and install dependencies
echo "Installing Python packages..."
source $VENV_DIR/bin/activate
pip install python-telegram-bot requests

# Download the Python script
echo "Downloading Telegram bot script..."
curl -o $BOT_SCRIPT_PATH $BOT_SCRIPT_URL

# Make the Python script executable
chmod +x $BOT_SCRIPT_PATH

# Create systemd service file
echo "Creating systemd service file..."
cat <<EOF > $SERVICE_FILE
[Unit]
Description=Telegram Bot for Proxmox
After=network.target

[Service]
ExecStart=$VENV_DIR/bin/python $BOT_SCRIPT_PATH
Restart=always
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=telegram_bot

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd and enable the service
echo "Reloading systemd and enabling service..."
systemctl daemon-reload
systemctl enable telegram_bot.service
systemctl start telegram_bot.service

# Check the status of the service
echo "Checking the status of the Telegram bot service..."
systemctl status telegram_bot.service

echo "Setup completed!"
