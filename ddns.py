#!/usr/bin/env python3

import requests
import json
import os
import logging
import sys

from dotenv import load_dotenv

# Charger la config
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s %(levelname)s %(message)s",
    handlers=[
        logging.StreamHandler(sys.stdout)
    ]
)

# Chemin vers le fichier .env
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
dotenv_path = '/etc/cloudflare-ddns/.env'
if not os.path.exists(dotenv_path):
	logging.warning("Using local .env file as /etc/cloudflare-ddns/.env not found.")
	dotenv_path = os.path.join(BASE_DIR, '.env')

load_dotenv(dotenv_path)

CLOUDFLARE_API_TOKEN = os.getenv("CLOUDFLARE_API_TOKEN")
ZONE_ID = os.getenv("ZONE_ID")
DNS_RECORD_NAME = os.getenv("DNS_RECORD_NAME")


HEADERS = {
    "Authorization": f"Bearer {CLOUDFLARE_API_TOKEN}",
    "Content-Type": "application/json"
}

def get_public_ip():
    response = requests.get("https://api.ipify.org?format=json", timeout=10)
    response.raise_for_status()
    return response.json()["ip"]

def get_dns_record():
    url = f"https://api.cloudflare.com/client/v4/zones/{ZONE_ID}/dns_records?type=A&name={DNS_RECORD_NAME}"
    response = requests.get(url, headers=HEADERS, timeout=10)
    response.raise_for_status()
    data = response.json()
    if data["success"] and data["result"]:
        return data["result"][0]
    else:
        raise Exception("DNS record not found")

def update_dns_record(record_id, ip):
    url = f"https://api.cloudflare.com/client/v4/zones/{ZONE_ID}/dns_records/{record_id}"
    data = {
        "type": "A",
        "name": DNS_RECORD_NAME,
        "content": ip,
        "ttl": 300,
        "proxied": False
    }
    response = requests.put(url, headers=HEADERS, data=json.dumps(data), timeout=10)
    response.raise_for_status()
    logging.info(f"DNS record updated to {ip}")

def main():
    try:
        public_ip = get_public_ip()
        logging.info(f"Current public IP: {public_ip}")
        dns_record = get_dns_record()
        logging.info(f"Current DNS record: {dns_record['content']} (ID: {dns_record['id']})")
        current_ip = dns_record["content"]
        logging.info(f"Current DNS record IP: {current_ip}")
        record_id = dns_record["id"]

        if public_ip != current_ip:
            logging.info(f"IP mismatch: DNS={current_ip} / Public={public_ip}. Updating...")
            update_dns_record(record_id, public_ip)
        else:
            logging.info("IP unchanged, nothing to do.")

    except Exception as e:
        logging.error(f"Error: {e}")

if __name__ == "__main__":
    main()
