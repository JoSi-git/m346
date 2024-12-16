#!/bin/bash

# Update die Paketliste
echo "Updating package list..."
sudo apt update

# Installiere Apache2
echo "Installing Apache2..."
sudo apt install -y apache2

# Starte den Apache-Dienst
echo "Starting Apache2 service..."
sudo systemctl start apache2

# Stelle sicher, dass Apache beim Booten startet
echo "Enabling Apache2 to start on boot..."
sudo systemctl enable apache2

# Überprüfen, ob Apache läuft
echo "Checking Apache2 status..."
sudo systemctl status apache2

# Teste die Installation, indem du die IP-Adresse des Servers aufrufst
echo "Apache installation complete. You can access the web server at http://<your-server-ip>"
