#!/bin/bash

# Schritt 1: Erstelle eine neue Elastic IP
echo "Erstelle eine frische Elastic IP-Adresse..."
NEW_ALLOCATION=$(aws ec2 allocate-address --query "AllocationId" --output text)

# Prüfe, ob die Erstellung erfolgreich war
if [ -z "$NEW_ALLOCATION" ]; then
  echo "Fehler: Konnte keine neue Elastic IP erstellen."
  exit 1
fi

echo "Elastic IP erfolgreich erstellt. Zuordnung-ID: $NEW_ALLOCATION"

# Schritt 2: Hole die öffentliche IP der neu erstellten Elastic IP (optional)
NEW_PUBLIC_IP=$(aws ec2 describe-addresses \
  --allocation-ids "$NEW_ALLOCATION" \
  --query "Addresses[0].PublicIp" --output text)

echo "Die öffentliche IP der neuen Elastic IP ist: $NEW_PUBLIC_IP"

# Schritt 3: Ermittle die Ziel-Instanz-ID basierend auf einem Tag
echo "Suche die Ziel-Instanz-ID basierend auf einem Tag..."
TARGET_INSTANCE=$(aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=WebApp" \
  --query "Reservations[].Instances[].InstanceId" --output text)

# Überprüfe, ob eine Instanz-ID gefunden wurde
if [ -z "$TARGET_INSTANCE" ]; then
  echo "Fehler: Keine Instanz-ID gefunden. Bitte den Filter überprüfen."
  exit 1
fi

echo "Gefundene Instanz-ID: $TARGET_INSTANCE"

# Schritt 4: Verknüpfe die neue Elastic IP mit der Instanz
echo "Verknüpfe die neue Elastic IP mit der Ziel-Instanz..."
aws ec2 associate-address --instance-id "$TARGET_INSTANCE" --allocation-id "$NEW_ALLOCATION"

# Prüfe, ob die Verknüpfung erfolgreich war
if [ $? -eq 0 ]; then
  echo "Die Elastic IP $NEW_PUBLIC_IP wurde erfolgreich mit der Instanz $TARGET_INSTANCE verknüpft."
else
  echo "Fehler beim Verknüpfen der Elastic IP mit der Instanz."
  exit 1
fi
