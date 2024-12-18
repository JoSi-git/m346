#!/bin/bash
set -e  # Beendet das Skript bei Fehlern
source ./config_files/variables.sh

cat << 'EOF'
 ____      _ ____            _____ ____   ____ ____   __        __            _                           ___           _        _ _           
|  _ \    | / ___|          | ____|  _ \ / ___|___ \  \ \      / /__  _ __ __| |_ __  _ __ ___  ___ ___  |_ _|_ __  ___| |_ __ _| | | ___ _ __ 
| | | |_  | \___ \   _____  |  _| | | | | |     __) |  \ \ /\ / / _ \| '__/ _` | '_ \| '__/ _ \/ __/ __|  | || '_ \/ __| __/ _` | | |/ _ \ '__|
| |_| | |_| |___) | |_____| | |___| |_| | |___ / __/    \ V  V / (_) | | | (_| | |_) | | |  __/\__ \__ \  | || | | \__ \ || (_| | | |  __/ |   
|____/ \___/|____/          |_____|____/ \____|_____|    \_/\_/ \___/|_|  \__,_| .__/|_|  \___||___/___/ |___|_| |_|___/\__\__,_|_|_|\___|_|   
                                                                               |_|
EOF
echo "-----------------------------------------------------------------------------------------------------------------------------------------------------"
echo -e "\e[1mFür alle Anforderungen, Hilfestellungen und Dokumentationen zum Skript, besuchen Sie bitte das Git-Repository unter: https://github.com/JoSi-git/m346.\e[0m"
echo ""

# Script für Sicherheitsgruppe und Key Pair
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

echo ""
echo "-----------------------------------------------------------------------------------------------------------------------------------------------------"

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
