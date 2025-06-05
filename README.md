![GitHub License](https://img.shields.io/github/license/MaxTeiger/cloudflare-ddns)

# Cloudflare DDNS - Raspberry Pi Edition (Systemd + Venv)

A lightweight personal service that automatically updates a Cloudflare A DNS record to point to your machine's current public IP (Raspberry Pi, home server, VPS, etc.).

✅ Fully compatible with ARM / Raspberry Pi OS Bookworm  
✅ Self-contained deployment using local Python venv  
✅ Clean logging via `journalctl` (systemd native)  
✅ Periodic execution using systemd timers

---

## How It Works

- Retrieves public IP using `api.ipify.org`
- Queries your current Cloudflare DNS A record
- Updates the record if the IP has changed
- Managed entirely via systemd (oneshot service + timer)
- All logs centralized in `journalctl` (no file logging required)

---

## Requirements

- Raspberry Pi (ARM64 recommended) or any Linux system
- Python 3.11+
- A Cloudflare account with:
  - API Token (with Zone DNS Edit permissions)
  - Zone ID of your Cloudflare DNS zone

---

## Installation

### 1️⃣ Clone the repository

```bash
git clone https://github.com/MaxTeiger/cloudflare-ddns.git
cd cloudflare-ddns
```

### 2️⃣ Build local Python venv (for dependency installation) - If you want to test it locally, can be skipped

```bash
bash scripts/build.sh
```

*This creates a local virtual environment and installs required dependencies.*

### 3️⃣ Run the system-wide installer

```bash
bash scripts/install.sh
```

* This copies the files into `/opt/cloudflare-ddns/` and `/etc/cloudflare-ddns/`
* Creates the Python venv directly in `/opt/cloudflare-ddns/venv/`
* Installs the systemd service and timer units

### 4️⃣ Configure Cloudflare credentials

```bash
sudo vim /opt/cloudflare-ddns/.env
```

Fill in the following variables:

```env
CLOUDFLARE_API_TOKEN=your_cloudflare_api_token
ZONE_ID=your_cloudflare_zone_id
DNS_RECORD_NAME=subdomain.example.com
```

### 5️⃣ Start the service

```bash
sudo systemctl start cloudflare-ddns.timer
```

---

## Logs

All logs are fully captured via systemd:

```bash
journalctl -u cloudflare-ddns.service -f
```

---

## Uninstall

To completely remove the service:

```bash
sudo bash scripts/uninstall.sh
```

---

## Why venv instead of static builds?

* Native PyInstaller builds on ARM with Debian Bookworm can be unreliable due to shared library issues.
* Local venv is fully isolated, reproducible, and portable on Raspberry Pi OS.
* This approach avoids PyInstaller and static linking complexities entirely.

---

## Roadmap (optional future improvements)

* Support multiple Cloudflare records
* Dockerized version
* Email or webhook notifications on failure
* Retry logic for transient errors

