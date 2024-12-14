#!/bin/bash
set -e  # Beendet das Skript bei Fehlern

# Key Pair erstellen
if [ ! -f ~/.ssh/djs-key.pem ]; then
    echo "Erstelle Key Pair..."
    mkdir -p ~/.ssh
    aws ec2 create-key-pair --key-name djs-key --key-type rsa --query 'KeyMaterial' --output text > ~/.ssh/djs-key.pem
    chmod 400 ~/.ssh/djs-key.pem
else
    echo "Key Pair ~/.ssh/djs-key.pem existiert bereits."
fi

# Sicherheitsgruppe erstellen
SEC_GROUP_NAME="djs-sec-group"
echo "Erstelle Sicherheitsgruppe..."
if ! aws ec2 describe-security-groups --group-names $SEC_GROUP_NAME &>/dev/null; then
    aws ec2 create-security-group --group-name $SEC_GROUP_NAME --description "EC2-Webserver-DJS"
    aws ec2 authorize-security-group-ingress --group-name $SEC_GROUP_NAME --protocol tcp --port 80 --cidr 0.0.0.0/0
    aws ec2 authorize-security-group-ingress --group-name $SEC_GROUP_NAME --protocol tcp --port 22 --cidr 0.0.0.0/0
else
    echo "Sicherheitsgruppe $SEC_GROUP_NAME existiert bereits."
fi

# Sicherstellen, dass das Verzeichnis existiert
if [ ! -d ~/ec2webserver ]; then
    echo "Erstelle Verzeichnis ~/ec2webserver..."
    mkdir -p ~/ec2webserver
fi

# Prüfen, ob initial.txt existiert
USER_DATA_FILE="initial.txt"
if [ ! -f $USER_DATA_FILE ]; then
    echo "Fehler: $USER_DATA_FILE nicht gefunden. Erstelle die Datei oder überprüfe den Pfad."
    exit 1
fi

# EC2-Instanz starten
echo "Starte EC2-Instanz..."
aws ec2 run-instances \
    --image-id ami-08c40ec9ead489470 \
    --count 1 \
    --instance-type t2.micro \
    --key-name djs-key \
    --security-groups $SEC_GROUP_NAME \
    --user-data file://$USER_DATA_FILE \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=Webserver}]'

# Öffentliche IP-Adresse der Instanz abrufen
echo "Öffentliche IP-Adresse der EC2-Instanz:"
aws ec2 describe-instances --query "Reservations[*].Instances[*].PublicIpAddress" --output text