#!/bin/bash

# Build le binaire standalone
echo "Building standalone binary with PyInstaller..."
pip install -r requirements.txt
pyinstaller --onefile ddns.py

echo "Build complete. Binary located in dist/ddns"
