#!/bin/bash
set -e  # Beendet das Skript bei Fehlern

# Update die Paketliste
echo "Updating package list..."
sudo apt update -y

sudo apt install mysql-server -y
sudo systemctl start mysql.service