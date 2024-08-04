#!/usr/bin/env bash

# Define necessary variables
TELEGRAM_BOT_TOKEN="5614449969:AAHyTMl-vt1jLoQ4uKifU0F656NHRTFwYSE"
NGROK_API_KEY="2kBcjD0HAI3PMzEtmHP2XNHIzz3_5w537UjyRkqFF6CGGAXg9"
PYTHON_SCRIPT_PATH="/opt/telegram_bot.py"
SYSTEMD_SERVICE_PATH="/etc/systemd/system/telegram_bot.service"

function header_info {
  clear
  cat <<"EOF"
   ________                ________                    __
  / ____/ /___  __  ______/ / __/ /___ _________  ____/ /
 / /   / / __ \/ / / / __  / /_/ / __ `/ ___/ _ \/ __  / 
/ /___/ / /_/ / /_/ / /_/ / __/ / /_/ / /  /  __/ /_/ /  
\____/_/\____/\__,_/\__,_/_/ /_/\__,_/_/   \___/\__,_/   
                                                         
EOF
}
header_info
echo -e "Loading..."

# Update and install necessary packages
function install_packages() {
  echo "Installing necessary packages..."
  apt-get update
  apt-get install -y python3 python3-pip curl
  pip3 install python-telegram-bot psutil requests
}

# Create the Python script for the Telegram bot
function create_python_script() {
  echo "Creating Python script for the Telegram bot..."
  cat <<EOF > $PYTHON_SCRIPT_PATH
import os
import subprocess
import time
import requests
from telegram import Update, Bot
from telegram.ext import Updater, CommandHandler, CallbackContext

TELEGRAM_BOT_TOKEN = '${TELEGRAM_BOT_TOKEN}'
NGROK_API_KEY = '${NGROK_API_KEY}'
ALLOWED_USERS = [658490863, 725718328]
NGROK_CMD = 'ngrok tcp 192.168.1.212:3389'
NGROK_URL = None

def start_ngrok():
    global NGROK_URL
    ngrok_process = subprocess.Popen(NGROK_CMD.split(), stdout=subprocess.PIPE)
    time.sleep(5)
    ngrok_api_url = "http://localhost:4040/api/tunnels"
    response = requests.get(ngrok_api_url).json()
    NGROK_URL = response['tunnels'][0]['public_url']

def start(update: Update, context: CallbackContext):
    update.message.reply_text('Bot is running!')

def rdp(update: Update, context: CallbackContext):
    if update.message.from_user.id not in ALLOWED_USERS:
        update.message.reply_text('You are not authorized to use this command.')
        return

    if not NGROK_URL:
        start_ngrok()
    update.message.reply_text(f'RDP URL: {NGROK_URL}')

def ping(update: Update, context: CallbackContext):
    if update.message.from_user.id not in ALLOWED_USERS:
        update.message.reply_text('You are not authorized to use this command.')
        return

    hostname = "192.168.1.212"
    response = os.system("ping -c 1 " + hostname)
    if response == 0:
        update.message.reply_text(f'{hostname} is up!')
    else:
        update.message.reply_text(f'{hostname} is down!')

def status(update: Update, context: CallbackContext):
    if update.message.from_user.id not in ALLOWED_USERS:
        update.message.reply_text('You are not authorized to use this command.')
        return

    uptime = os.popen('uptime').read()
    update.message.reply_text(f'System Status:\\n{uptime}')

def main():
    updater = Updater(TELEGRAM_BOT_TOKEN, use_context=True)
    dp = updater.dispatcher

    dp.add_handler(CommandHandler("start", start))
    dp.add_handler(CommandHandler("rdp", rdp))
    dp.add_handler(CommandHandler("ping", ping))
    dp.add_handler(CommandHandler("status", status))

    updater.start_polling()
    updater.idle()

if __name__ == '__main__':
    main()
EOF
  chmod +x $PYTHON_SCRIPT_PATH
}

# Create the systemd service file for the bot
function create_systemd_service() {
  echo "Creating systemd service for the Telegram bot..."
  cat <<EOF > $SYSTEMD_SERVICE_PATH
[Unit]
Description=Telegram Bot for Proxmox
After=network.target

[Service]
ExecStart=/usr/bin/python3 $PYTHON_SCRIPT_PATH
Restart=always

[Install]
WantedBy=multi-user.target
EOF

  # Enable and start the service
  systemctl daemon-reload
  systemctl enable telegram_bot.service
  systemctl start telegram_bot.service
}

# Run all the functions
install_packages
create_python_script
create_systemd_service

echo "Setup completed successfully!"
