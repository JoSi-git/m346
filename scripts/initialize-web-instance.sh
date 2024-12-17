#!/bin/bash
set -e  # Beendet das Skript bei Fehlern

# Variablen definieren
source ./config_files/variables.sh

# Sicherstellen, dass das Verzeichnis existiert
if [ ! -d ~/ec2webserver ]; then
    echo "Erstelle Verzeichnis ~/ec2webserver..."
    mkdir -p ~/ec2webserver
fi

# Prüfen, ob wpinstall.sh existiert
Wordpress_installation_File="./config_files/wpinstall.sh"
if [ ! -f $Wordpress_installation_File ]; then
    echo "Fehler: $Wordpress_installation_File nicht gefunden. Erstelle die Datei oder überprüfe den Pfad."
    exit 1
fi

# Starte die Instanz und extrahiere die Instanz-ID direkt
echo "Starte Webserver EC2-Instanz..."
export AWS_PAGER=""

INSTANCE_ID1=$(aws ec2 run-instances \
--image-id ami-08c40ec9ead489470 \
--count 1 \
--instance-type t2.micro \
--key-name djs-key \
--security-groups $SEC_GROUP_NAME \
--tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=Webserver}]' \
--query 'Instances[0].InstanceId' \
--output text)

# Prüfe, ob eine Instanz-ID zurückgegeben wurde
if [ -z "$INSTANCE_ID2" ]; then
    echo "Fehler: Keine Instanz-ID erhalten."
    exit 1
fi

echo "Gestartete Instanz-ID: $INSTANCE_ID2"

# Ermittle die Public IP der Instanz
PUBLIC_IP2=$(aws ec2 describe-instances \
--instance-ids "$INSTANCE_ID2" \
--query "Reservations[].Instances[].PublicIpAddress" \
--output text)

# Prüfe, ob eine Public IP gefunden wurde
if [ -z "$PUBLIC_IP2" ]; then
    echo "Fehler: Keine Public IP gefunden."
    exit 1
fi

# Initialisierungsprozess abwarten
sleep $SLEEP_DURATION

echo "Gefundene Public IP: $PUBLIC_IP2"

# SSH-Verbindung herstellen und wpinstall.sh ausführen
echo "Kopiere das wpinstall.sh-Skript auf die Instanz..."
# Kopiere das Skript auf die Instanz
scp -i ~/.ssh/djs-key.pem -o StrictHostKeyChecking=accept-new ./config_files/wpinstall.sh ubuntu@"$PUBLIC_IP2":/home/ubuntu/wpinstall.sh
scp -i ~/.ssh/djs-key.pem -o StrictHostKeyChecking=accept-new ./config_files/variables.sh ubuntu@"$PUBLIC_IP2":/home/ubuntu/variables.sh

# Prüfe, ob der Upload erfolgreich war
if [ $? -ne 0 ]; then
    echo "Fehler: Das Skript konnte nicht auf die Instanz kopiert werden."
    exit 1
fi

# SSH-Konfigurationsabschnitt
echo "-------------------------------------------------------------------------------------"

# Führe das WordPress-Installationsskript auf der Instanz aus
echo "Führe das WordPress-Installationsskript auf der Instanz aus..."
ssh -i ~/.ssh/djs-key.pem -o StrictHostKeyChecking=accept-new ubuntu@"$PUBLIC_IP2" << 'EOF'
    echo "Setze Berechtigungen für wpinstall.sh.."
    chmod +x /home/ubuntu/wpinstall.sh
    echo "Starte die Ausführung von wpinstall.sh..."
    /home/ubuntu/wpinstall.sh
EOF

echo "-------------------------------------------------------------------------------------"

# Prüfe, ob die Ausführung erfolgreich war
if [ $? -ne 0 ]; then
    echo "Fehler: Das WordPress-Installationsskript konnte nicht erfolgreich ausgeführt werden."
    exit 1
else
    echo "WordPress-Installation erfolgreich abgeschlossen!"
fi

# Tabellarische Ausgabe von Instanznummer und IP Addresse
echo "+------------------------------+------------------------------+"  
printf "| %-30s | %-30s |\n" "Instanz-ID" "Öffentliche IP"
echo "+------------------------------+------------------------------+"  
printf "| %-30s | %-30s |\n" "$INSTANCE_ID2" "$PUBLIC_IP2"
echo "+------------------------------+------------------------------+"  

# variablen in file schrieben
echo "INSTANCE_ID2=\"$INSTANCE_ID2\"" >> ./config_files/variables.sh
echo "PUBLIC_IP2=\"$PUBLIC_IP2\"" >> ./config_files/variables.sh
echo "Wordpress_installation_File=\"$Wordpress_installation_File\"" >> ./config_files/variables.sh
