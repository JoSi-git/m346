#!/bin/bash
set -e  # Beendet das Skript bei Fehlern

# Variablen
KEY_NAME="djs-key"
SEC_GROUP_NAME="djs-sec-group"

# EC2-Instanz(en) suchen und beenden
echo "Suche EC2-Instanz(en) mit Sicherheitsgruppe $SEC_GROUP_NAME..."
INSTANCE_IDS=$(aws ec2 describe-instances --filters "Name=instance.group-name,Values=$SEC_GROUP_NAME" \
    --query "Reservations[*].Instances[*].InstanceId" --output text)

if [ -n "$INSTANCE_IDS" ]; then
    echo "Beende und lösche EC2-Instanz(en): $INSTANCE_IDS..."
    aws ec2 terminate-instances --instance-ids $INSTANCE_IDS
    aws ec2 wait instance-terminated --instance-ids $INSTANCE_IDS
    echo "Instanz(en) erfolgreich gelöscht."
else
    echo "Keine EC2-Instanz mit der Sicherheitsgruppe $SEC_GROUP_NAME gefunden."
fi

# Sicherheitsgruppe löschen
echo "Lösche Sicherheitsgruppe $SEC_GROUP_NAME..."
if aws ec2 describe-security-groups --group-names $SEC_GROUP_NAME &>/dev/null; then
    aws ec2 delete-security-group --group-name $SEC_GROUP_NAME
    echo "Sicherheitsgruppe $SEC_GROUP_NAME gelöscht."
else
    echo "Sicherheitsgruppe $SEC_GROUP_NAME existiert nicht."
fi

# Key Pair löschen
echo "Lösche Key Pair $KEY_NAME..."
if aws ec2 describe-key-pairs --key-names $KEY_NAME &>/dev/null; then
    aws ec2 delete-key-pair --key-name $KEY_NAME
    rm -f ~/.ssh/${KEY_NAME}.pem
    echo "Key Pair $KEY_NAME gelöscht."
else
    echo "Key Pair $KEY_NAME existiert nicht."
fi

echo "Alle Ressourcen wurden erfolgreich entfernt."
