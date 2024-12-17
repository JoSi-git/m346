#!/bin/bash
set -e  # Beendet das Skript bei Fehlern

# Variablen definieren
source ./config_files/variables.sh

# Update die Paketliste
echo "Updating package list..."
sudo apt update -y

sudo apt install mysql-server -y
sudo systemctl start mysql.service