#!/bin/bash
set -e

# Get absolute path to the directory containing this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Create installation directories
echo "[*] Creating installation directories"
sudo mkdir -p /opt/cloudflare-ddns
sudo mkdir -p /etc/cloudflare-ddns

# Copy source code and dependencies
echo "[*] Copying source code and dependencies"
sudo cp "${SCRIPT_DIR}/ddns.py" /opt/cloudflare-ddns/
sudo cp "${SCRIPT_DIR}/requirements.txt" /opt/cloudflare-ddns/

# Create Python virtual environment inside /opt
echo "[*] Creating Python virtual environment in /opt/cloudflare-ddns"
cd /opt/cloudflare-ddns
sudo python3 -m venv venv
sudo venv/bin/pip install -r requirements.txt

# Copy config file if it doesn't exist yet
if [ ! -f /etc/cloudflare-ddns/.env ]; then
  echo "[*] .env config file not found, copying template"
  sudo cp "${SCRIPT_DIR}/.env.example" /etc/cloudflare-ddns/.env
  echo "    [!!] Remember to edit /etc/cloudflare-ddns/.env"
fi

# Install systemd unit files
echo "[*] Installing systemd service files"
sudo cp "${SCRIPT_DIR}/service/cloudflare-ddns.service" /etc/systemd/system/
sudo cp "${SCRIPT_DIR}/service/cloudflare-ddns.timer" /etc/systemd/system/

# Enable systemd timer
echo "[*] Enabling systemd service"
sudo systemctl daemon-reload
sudo systemctl enable cloudflare-ddns.timer

echo "[*] Installation complete"
sudo systemctl start cloudflare-ddns.timer
echo "[*] cloudflare-ddns service started"
echo "[*] You can check status with: systemctl status cloudflare-ddns.service"
