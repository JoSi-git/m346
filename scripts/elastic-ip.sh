#!/bin/bash
set -e  # Beendet das Skript bei Fehlern

# Variablen aus der Konfigurationsdatei laden
source ./config_files/variables.sh

# Überprüfen, welcher Schritt der Konfiguration ausgeführt werden soll
if [[ "$CONFIG_STEP" == "1" ]]; then
    echo "Starte Konfiguration der Elastic IP für Instanz 1 ($INSTANCE_ID1)..."

    # Neue Elastic IP erstellen
    NEW_ALLOCATION=$(aws ec2 allocate-address --query "AllocationId" --output text)

    if [ -z "$NEW_ALLOCATION" ]; then
        echo "Fehler: Konnte keine neue Elastic IP erstellen."
        exit 1
    fi

    echo "Neue Elastic IP erfolgreich erstellt. Zuordnung-ID: $NEW_ALLOCATION"

    # Elastic IP mit Instanz 1 verknüpfen
    aws ec2 associate-address --instance-id "$INSTANCE_ID1" --allocation-id "$NEW_ALLOCATION"

    # Öffentliche IP der Elastic IP abrufen
    NEW_PUBLIC_IP=$(aws ec2 describe-addresses --allocation-ids "$NEW_ALLOCATION" --query "Addresses[0].PublicIp" --output text)
    echo "Die neue öffentliche IP für Instanz 1 lautet: $NEW_PUBLIC_IP"

    # Aktualisiere PUBLIC_IP1 in der Konfigurationsdatei
    sed -i "s|^PUBLIC_IP1=.*|PUBLIC_IP1=\"$NEW_PUBLIC_IP\"|" ./config_files/variables.sh

    # Aktualisiere den Status der Konfiguration
    sed -i "s|^CONFIG_STEP=.*|CONFIG_STEP=2|" ./config_files/variables.sh
    echo "Konfiguration von Instanz 1 abgeschlossen."

    # Tabellarische Ausgabe von Instanznummer und IP Addresse
    echo "+------------------------------+------------------------------+"  
    printf "| %-30s | %-30s |\n" "Instanz-ID" "Öffentliche IP"
    echo "+------------------------------+------------------------------+"  
    printf "| %-30s | %-30s |\n" "$INSTANCE_ID1" "$PUBLIC_IP1"
    echo "+------------------------------+------------------------------+"  

elif [[ "$CONFIG_STEP" == "2" ]]; then
    echo "Starte Konfiguration der Elastic IP für Instanz 2 ($INSTANCE_ID2)..."

    # Neue Elastic IP erstellen
    NEW_ALLOCATION=$(aws ec2 allocate-address --query "AllocationId" --output text)

    if [ -z "$NEW_ALLOCATION" ]; then
        echo "Fehler: Konnte keine neue Elastic IP erstellen."
        exit 1
    fi

    echo "Neue Elastic IP erfolgreich erstellt. Zuordnung-ID: $NEW_ALLOCATION"

    # Elastic IP mit Instanz 2 verknüpfen
    aws ec2 associate-address --instance-id "$INSTANCE_ID2" --allocation-id "$NEW_ALLOCATION"

    # Öffentliche IP der Elastic IP abrufen
    NEW_PUBLIC_IP=$(aws ec2 describe-addresses --allocation-ids "$NEW_ALLOCATION" --query "Addresses[0].PublicIp" --output text)
    echo "Die neue öffentliche IP für Instanz 2 lautet: $NEW_PUBLIC_IP"

    # Aktualisiere PUBLIC_IP2 in der Konfigurationsdatei
    sed -i "s|^PUBLIC_IP2=.*|PUBLIC_IP2=\"$NEW_PUBLIC_IP\"|" ./config_files/variables.sh

    # Aktualisiere den Status der Konfiguration (auf abgeschlossen setzen)
    sed -i "s|^CONFIG_STEP=.*|CONFIG_STEP=done|" ./config_files/variables.sh
    echo "Konfiguration von Instanz 2 abgeschlossen."
    echo""

    # Tabellarische Ausgabe von Instanznummer und IP Addresse
    echo "Mit den folgenden Daten kann auf die fertige WordPress-Instanz zugegriffen werden:"
    echo "+------------------------------+------------------------------+"  
    printf "| %-30s | %-30s |\n" "Instanz-ID" "Öffentliche IP"
    echo "+------------------------------+------------------------------+"  
    printf "| %-30s | %-30s |\n" "$INSTANCE_ID2" "$NEW_PUBLIC_IP"
    echo "+------------------------------+------------------------------+"  

else
    echo "Alle Elastic IPs wurden bereits konfiguriert. Keine weiteren Schritte erforderlich."
    exit 0
fi
