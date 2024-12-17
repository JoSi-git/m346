#!/bin/bash
set -e  # Beendet das Skript bei Fehlern

# Update die Paketliste
echo "Updating package list..."
sudo apt update -y

# Installiere Apache2
echo "Installing Apache2..."
sudo apt install apache2 -y

# Starte den Apache-Dienst
echo "Starting Apache2 service..."
sudo systemctl start apache2

# Stelle sicher, dass Apache beim Booten startet
echo "Enabling Apache2 to start on boot..."
sudo systemctl enable apache2

# Überprüfen, ob Apache läuft
echo "Checking Apache2 status..."
sudo systemctl status apache2
