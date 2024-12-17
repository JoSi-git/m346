#!/bin/bash
set -e  # Beendet das Skript bei Fehlern
source ./config_files/variables.sh

echo ""
echo "DJS EDC2 Wordpress Installer"
echo "-------------------------------------------------------------------------------------"
echo "Für alle Anforderungen, Hilfestellungen und Dokumentationen zum Skript, besuchen Sie bitte das Git-Repository unter: https://github.com/JoSi-git/m346."
echo ""

# run script für Sicherheitsgruppe und Key Pair
bash ./scripts/sec-key.sh

# AWS MySQL-Instanz initialisieren
bash ./scripts/initialize-mysql-instance.sh

if [[ $? -ne 0 ]]; then
    echo "Fehler: initialize-mysql-instance.sh konnte nicht erfolgreich ausgeführt werden."
    echo "Installation wird abgebrochen."
    exit 1
fi

# Elastic IP für MySQL konfigurieren
echo "Konfiguriere Elastic IP für MySQL..."
./scripts/elastic-ip.sh

echo "-------------------------------------------------------------------------------------"

# AWS Webserver-Instanz initialisieren
bash ./scripts/initialize-web-instance.sh

if [[ $? -ne 0 ]]; then
    echo "Fehler: initialize-web-instance.sh konnte nicht erfolgreich ausgeführt werden."
    echo "Installation wird abgebrochen."
    exit 1
fi

# Elastic IP für den Webserver konfigurieren
echo "Konfiguriere Elastic IP für Webserver..."
./scripts/elastic-ip.sh

# Installation abschliessen
echo "Installation abgeschlossen."
