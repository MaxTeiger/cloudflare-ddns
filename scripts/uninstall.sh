#!/bin/bash
set -e

sudo systemctl stop cloudflare-ddns.timer
sudo systemctl disable cloudflare-ddns.timer
sudo systemctl disable cloudflare-ddns.service
sudo rm /etc/systemd/system/cloudflare-ddns.*
sudo rm -rf /opt/cloudflare-ddns
sudo rm -rf /etc/cloudflare-ddns
sudo systemctl daemon-reload
