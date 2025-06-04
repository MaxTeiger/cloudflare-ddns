#!/bin/bash
set -e

# Récupérer le chemin absolu du dossier contenant ce script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Création du dossier d'installation
echo "[*] Création des dossiers de l'installation"
sudo mkdir -p /opt/cloudflare-ddns
sudo mkdir -p /etc/cloudflare-ddns

# Copier le code source et les dépendances
echo "[*] Copie du code source et des dépendances"
sudo cp "${SCRIPT_DIR}/ddns.py" /opt/cloudflare-ddns/
sudo cp "${SCRIPT_DIR}/requirements.txt" /opt/cloudflare-ddns/

# Création du venv dans /opt
echo "[*] Création de l'environnement virtuel Python"
cd /opt/cloudflare-ddns
sudo python3 -m venv venv
sudo venv/bin/pip install -r requirements.txt

# Copie du fichier de config s'il n'existe pas encore
if [ ! -f /etc/cloudflare-ddns/.env ]; then
  echo "[*] Fichier de configuration .env non trouvé, copie du modèle"
  sudo cp "${SCRIPT_DIR}/.env.example" /etc/cloudflare-ddns/.env
  echo "    [!!] Pense à éditer /etc/cloudflare-ddns/.env"
fi

# Installer les fichiers systemd
echo "[*] Installation des fichiers systemd"
sudo cp "${SCRIPT_DIR}/service/cloudflare-ddns.service" /etc/systemd/system/
sudo cp "${SCRIPT_DIR}/service/cloudflare-ddns.timer" /etc/systemd/system/

# Activer systemd
echo "[*] Activation du service systemd"
sudo systemctl daemon-reload
sudo systemctl enable cloudflare-ddns.timer

echo "[*] Installation terminée"
sudo systemctl start cloudflare-ddns.timer
echo "[*] Le service cloudflare-ddns est démarré"
echo "[*] Tu peux vérifier l'état avec : systemctl status cloudflare-ddns.service"