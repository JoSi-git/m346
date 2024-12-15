#!/bin/bash

# run config, to setup aws ec2 as the webserver
bash ./scripts/config.sh

# Frage den Benutzer, ob eine Elastic IP konfiguriert werden soll
while true; do
    read -p "Möchten Sie eine Elastic IP konfigurieren? (j/n): " user_input

    # Überprüfe die Antwort des Benutzers
    if [[ "$user_input" == "j" || "$user_input" == "J" ]]; then
        # Aufruf des Scripts, wenn der Benutzer 'j' antwortet
        echo "Elastic IP wird konfiguriert..."
        ./scripts/elastic-ip.sh
        break  # Verlasse die Schleife, wenn der Vorgang abgeschlossen ist
    elif [[ "$user_input" == "n" || "$user_input" == "N" ]]; then
        # Ausgabe einer Nachricht, wenn der Benutzer 'n' antwortet
        echo "Installation beendet."
        break  # Verlasse die Schleife und beende das Skript
    else
        # Falls eine ungültige Eingabe gemacht wurde, erneut fragen
        echo "Ungültige Eingabe. Bitte nur 'j' oder 'n' eingeben."
    fi
done

# Installation abschliessen
echo "Installation wird abgeschlossen"
