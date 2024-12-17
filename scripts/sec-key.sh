#!/bin/bash
set -e  # Beendet das Skript bei Fehlern

# Variablen definieren
source ./config_files/variables.sh

# Key Pair erstellen
if [ ! -f ~/.ssh/$KEY_NAME.pem ]; then
    echo "Erstelle Key Pair..."
    mkdir -p ~/.ssh
    aws ec2 create-key-pair --key-name $KEY_NAME --key-type rsa --query 'KeyMaterial' --output text > ~/.ssh/$KEY_NAME.pem
    chmod 400 ~/.ssh/$KEY_NAME.pem
else
    echo "Key Pair ~/.ssh/$KEY_NAME.pem existiert bereits."
fi

# Sicherheitsgruppe erstellen
echo "Erstelle Sicherheitsgruppe..."
if ! aws ec2 describe-security-groups --group-names $SEC_GROUP_NAME &>/dev/null; then
    aws ec2 create-security-group --group-name $SEC_GROUP_NAME --description "EC2-Webserver-DJS"
    aws ec2 authorize-security-group-ingress --group-name $SEC_GROUP_NAME --protocol tcp --port 80 --cidr 0.0.0.0/0
    aws ec2 authorize-security-group-ingress --group-name $SEC_GROUP_NAME --protocol tcp --port 22 --cidr 0.0.0.0/0
else
    echo "Sicherheitsgruppe $SEC_GROUP_NAME existiert bereits."
fi
