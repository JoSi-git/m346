#!/bin/bash
set -e  # Beendet das Skript bei Fehlern

# Variablen definieren
source /home/ubuntu/variables.sh

# Update die Paketliste
echo "Updating package list..."
sudo apt update -y

sudo apt install mysql-server -y
sudo systemctl start mysql.service