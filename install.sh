#!/bin/bash
set -e  # Beendet das Skript bei Fehlern

echo ""
echo "DJS EDC2 Wordpress Installer"
echo "-------------------------------------------------------------------------------------"
echo "Für alle Anforderungen, Hilfestellungen und Dokumentationen zum Skript, besuchen Sie bitte das Git-Repository unter: https://github.com/JoSi-git/m346."
echo ""

# Funktion zur Konfiguration der Elastic IP
configure_elastic_ip() {
    while true; do
        read -p "Möchten Sie eine Elastic IP konfigurieren? (j/n): " user_input

        if [[ "$user_input" == "j" || "$user_input" == "J" ]]; then
            echo "Elastic IP wird konfiguriert..."
            ./scripts/elastic-ip.sh
            break
        elif [[ "$user_input" == "n" || "$user_input" == "N" ]]; then
            echo "Elastic IP Konfiguration wird beendet."
            break
        else
            echo "Ungültige Eingabe. Bitte nur 'j' oder 'n' eingeben."
        fi
    done
}

# run config, to setup aws ec2 as the MySQL Server
bash ./scripts/initialize-mysql-instance.sh

if [[ $? -ne 0 ]]; then
    echo "Fehler: initialize-mysql-instance.sh konnte nicht erfolgreich ausgeführt werden."
    echo "Installation wird abgebrochen."
    exit 1
fi

# Elastic IP für MySQL konfigurieren
configure_elastic_ip

# Optische Trennung beider Skripts
echo "-------------------------------------------------------------------------------------"

# run config, to setup aws ec2 as the Web Server
bash ./scripts/initialize-web-instance.sh

if [[ $? -ne 0 ]]; then
    echo "Fehler: initialize-web-instance.sh konnte nicht erfolgreich ausgeführt werden."
    echo "Installation wird abgebrochen."
    exit 1
fi

# Elastic IP für den Webserver konfigurieren
configure_elastic_ip

# Installation abschließen
echo "Installation wird abgeschlossen"
