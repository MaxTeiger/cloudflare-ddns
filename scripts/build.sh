#!/bin/bash
set -e

# Création du venv local
python3 -m venv venv

# Activation du venv
source venv/bin/activate

# Installation des dépendances
pip install -r requirements.txt

echo "[*] Build terminé (venv localisé dans ./venv)"