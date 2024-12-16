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

# Prüfen, ob wpinstall.sh existiert
Wordpress_installation_File="./config_files/wpinstall.sh"
if [ ! -f $Wordpress_installation_File ]; then
    echo "Fehler: $Wordpress_installation_File nicht gefunden. Erstelle die Datei oder überprüfe den Pfad."
    exit 1
fi

# Starte die Instanz und extrahiere die Instanz-ID direkt
echo "Starte EC2-Instanz..."
export AWS_PAGER=""

INSTANCE_ID=$(aws ec2 run-instances \
--image-id ami-08c40ec9ead489470 \
--count 1 \
--instance-type t2.micro \
--key-name djs-key \
--security-groups $SEC_GROUP_NAME \
--tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=Webserver}]' \
--query 'Instances[0].InstanceId' \
--output text)

# Prüfe, ob eine Instanz-ID zurückgegeben wurde
if [ -z "$INSTANCE_ID" ]; then
    echo "Fehler: Keine Instanz-ID erhalten."
    exit 1
fi

echo "Gestartete Instanz-ID: $INSTANCE_ID"

# Warte auf Instanz-Bereitschaft
echo "Warte auf Instanz-Bereitschaft..."
aws ec2 wait instance-running --instance-ids "$INSTANCE_ID"

# Ermittle die Public IP der Instanz
PUBLIC_IP=$(aws ec2 describe-instances \
--instance-ids "$INSTANCE_ID" \
--query "Reservations[].Instances[].PublicIpAddress" \
--output text)

# Prüfe, ob eine Public IP gefunden wurde
if [ -z "$PUBLIC_IP" ]; then
    echo "Fehler: Keine Public IP gefunden."
    exit 1
fi

echo "Gefundene Public IP: $PUBLIC_IP"

# SSH-Verbindung herstellen und wpinstall.sh ausführen
echo "Kopiere das install_wordpress.sh-Skript auf die Instanz..."

# Kopiere das Skript auf die Instanz
scp -i ~/.ssh/djs-key.pem -o StrictHostKeyChecking=accept-new ./config_files/wpinstall.sh ubuntu@"$PUBLIC_IP":/home/ubuntu/wpinstall.sh

# Prüfe, ob der Upload erfolgreich war
if [ $? -ne 0 ]; then
    echo "Fehler: Das Skript konnte nicht auf die Instanz kopiert werden."
    exit 1
fi

# Führe das WordPress-Installationsskript auf der Instanz aus
echo "Führe das WordPress-Installationsskript auf der Instanz aus..."
ssh -i ~/.ssh/djs-key.pem -o StrictHostKeyChecking=accept-new ubuntu@"$PUBLIC_IP" << 'EOF'
    echo "Setze Berechtigungen für wpinstall.sh.."
    chmod +x /home/ubuntu/wpinstall.sh
    echo "Starte die Ausführung von wpinstall.sh..."
    /home/ubuntu/wpinstall.sh
EOF

# Prüfe, ob die Ausführung erfolgreich war
if [ $? -ne 0 ]; then
    echo "Fehler: Das WordPress-Installationsskript konnte nicht erfolgreich ausgeführt werden."
    exit 1
else
    echo "WordPress-Installation erfolgreich abgeschlossen!"
fi

# Öffentliche IP-Adresse der Instanz abrufen
echo "Instanz-ID und öffentliche IP-Adresse der EC2-Instanzen:"
aws ec2 describe-instances --query "Reservations[*].Instances[*].[InstanceId, PublicIpAddress]" --output table | sed 's/DescribeInstances/EC2-Instanzen/'