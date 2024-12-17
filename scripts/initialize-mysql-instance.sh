#!/bin/bash
set -e  # Beendet das Skript bei Fehlern

# Variablen definieren
source ./config_files/variables.sh

# Sicherstellen, dass das Verzeichnis existiert
if [ ! -d ~/ec2webserver ]; then
    echo "Erstelle Verzeichnis ~/ec2mysqlserver..."
    mkdir -p ~/ec2mysqlserver
fi

# Prüfen, ob mysqlinstall.sh existiert
MySQL_installation_File="./config_files/mysqlinstall.sh"
if [ ! -f $MySQL_installation_File ]; then
    echo "Fehler: $MySQL_installation_File nicht gefunden. Erstelle die Datei oder überprüfe den Pfad."
    exit 1
fi

# Starte die MySQL Instanz und extrahiere die Instanz-ID direkt
echo "Starte MySQL EC2-Instanz..."
export AWS_PAGER=""

INSTANCE_ID1=$(aws ec2 run-instances \
--image-id ami-08c40ec9ead489470 \
--count 1 \
--instance-type t2.micro \
--key-name $KEY_NAME \
--security-groups $SEC_GROUP_NAME \
--tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=Webserver}]' \
--query 'Instances[0].InstanceId' \
--output text)

# Prüfe, ob eine Instanz-ID zurückgegeben wurde
if [ -z "$INSTANCE_ID1" ]; then
    echo "Fehler: Keine Instanz-ID erhalten."
    exit 1
fi

echo "Gestartete Instanz-ID: $INSTANCE_ID1"

# Ermittle die Public IP der Instanz
PUBLIC_IP1=$(aws ec2 describe-instances \
--instance-ids "$INSTANCE_ID1" \
--query "Reservations[].Instances[].PublicIpAddress" \
--output text)

# Prüfe, ob eine Public IP gefunden wurde
if [ -z "$PUBLIC_IP1" ]; then
    echo "Fehler: Keine Public IP gefunden."
    exit 1
fi

# Initialisierungsprozess abwarten
sleep $SLEEP_DURATION

echo "Gefundene Public IP: $PUBLIC_IP1"

# SSH-Verbindung herstellen und mysqlinstall.sh ausführen
echo "Kopiere das install_MySQL.sh-Skript auf die Instanz..."
# Kopiere das Skript auf die Instanz
scp -i ~/.ssh/$KEY_NAME.pem -o StrictHostKeyChecking=accept-new ./config_files/mysqlinstall.sh ubuntu@"$PUBLIC_IP1":/home/ubuntu/mysqlinstall.sh


# Prüfe, ob der Upload erfolgreich war
if [ $? -ne 0 ]; then
    echo "Fehler: Das Skript konnte nicht auf die Instanz kopiert werden."
    exit 1
fi

# SSH-Konfigurationsabschnitt
echo "-------------------------------------------------------------------------------------"

# Führe das MySQL-Installationsskript auf der Instanz aus
echo "Führe das MySQL-Installationsskript auf der Instanz aus..."
ssh -i ~/.ssh/$KEY_NAME.pem -o StrictHostKeyChecking=accept-new ubuntu@"$PUBLIC_IP1" << 'EOF'
    echo "Setze Berechtigungen für mysqlinstall.sh.."
    chmod +x /home/ubuntu/mysqlinstall.sh
    echo "Starte die Ausführung von mysqlinstall.sh..."
    /home/ubuntu/mysqlinstall.sh
EOF

echo "-------------------------------------------------------------------------------------"

# Prüfe, ob die Ausführung erfolgreich war
if [ $? -ne 0 ]; then
    echo "Fehler: Das MySQL-Installationsskript konnte nicht erfolgreich ausgeführt werden."
    exit 1
else
    echo "MySQL-Installation erfolgreich abgeschlossen!"
fi

# Tabellarische Ausgabe von Instanznummer und IP Addresse
echo "+------------------------------+------------------------------+"  
printf "| %-30s | %-30s |\n" "Instanz-ID" "Öffentliche IP"
echo "+------------------------------+------------------------------+"  
printf "| %-30s | %-30s |\n" "$INSTANCE_ID1" "$PUBLIC_IP1"
echo "+------------------------------+------------------------------+"  


# variablen in file schrieben
echo "INSTANCE_ID1=$INSTANCE_ID1" >> ./config_files/variables.sh
echo "PUBLIC_IP1=\"$PUBLIC_IP1\"" >> ./config_files/variables.sh
echo "MySQL_installation_File=\"$MySQL_installation_File\"" >> ./config_files/variables.sh