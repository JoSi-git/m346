#!/bin/bash
set -e  # Beendet das Skript bei Fehlern

# Variablen definieren
source ./config_files/variables.sh
FILE_PATH="./config_files/variables.sh"
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

# Elastic IPs löschen

# Alle Elastic IPs abrufen und als Text anzeigen
elastic_ips=$(aws ec2 describe-addresses --query 'Addresses[*].[AllocationId]' --output text)

# Überprüfen, ob Elastic IPs vorhanden sind
if [ -z "$elastic_ips" ]; then
    echo "Keine Elastic IPs gefunden."
    exit 1
else
    echo "Gefundene Elastic IPs:"
    echo "$elastic_ips"
fi

# Jede Elastic IP freigeben
for allocation_id in $elastic_ips; do
    echo "Freigeben der Elastic IP mit Allocation-ID: $allocation_id"
    aws ec2 release-address --allocation-id $allocation_id
    if [ $? -eq 0 ]; then
        echo "Elastic IP erfolgreich freigegeben."
    else
        echo "Fehler beim Freigeben der Elastic IP mit Allocation-ID: $allocation_id"
    fi
done

echo "Alle Ressourcen wurden erfolgreich entfernt."

if [ -f "$FILE_PATH" ]; then
    rm "$FILE_PATH"
    echo "Die Datei wurde gelöscht."
else
    echo "Die Datei existiert nicht."
fi

touch "$FILE_PATH"

echo "# Neue Werte für die Variablen" >> "$FILE_PATH"
echo "SLEEP_DURATION=\"20\"" >> "$FILE_PATH"
echo "KEY_NAME=\"djs-key\"" >> "$FILE_PATH"
echo "SEC_GROUP_NAME=\"djs-sec-group\"" >> "$FILE_PATH"
echo "CONFIG_STEP=1" >> "$FILE_PATH"

# variablen in file schrieben
echo "KEY_NAME=\"$KEY_NAME\"" >> ./config_files/variables.sh
echo "SEC_GROUP_NAME=\"$SEC_GROUP_NAME\"" >> ./config_files/variables.sh
