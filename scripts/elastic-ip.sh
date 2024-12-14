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

# Schritt 2: Hole alle Instanzen mit dem Tag Name (optional kannst du den Tag weiter anpassen)
echo "Suche alle Instanzen mit dem Tag Name..."
INSTANCES=$(aws ec2 describe-instances \
  --query "Reservations[].Instances[].[InstanceId,Tags[?Key=='Name'].Value | [0]]" \
  --output text)

# Wenn keine Instanzen gefunden wurden, beenden
if [ -z "$INSTANCES" ]; then
  echo "Fehler: Keine Instanzen gefunden."
  exit 1
fi

# Zeige die Instanzen an und lass den Benutzer eine auswählen
echo "Verfügbare Instanzen:"
echo "$INSTANCES" | nl

# Benutzer zur Auswahl auffordern
echo "Wählen Sie die Instanz aus (geben Sie die Nummer ein):"
read -p "Instanznummer: " SELECTION

# Holen der Instanz-ID basierend auf der Auswahl
SELECTED_INSTANCE=$(echo "$INSTANCES" | sed -n "${SELECTION}p" | awk '{print $1}')

# Überprüfen, ob eine Instanz-ID ausgewählt wurde
if [ -z "$SELECTED_INSTANCE" ]; then
  echo "Fehler: Ungültige Auswahl."
  exit 1
fi

echo "Ausgewählte Instanz-ID: $SELECTED_INSTANCE"

# Schritt 3: Verknüpfe die neue Elastic IP mit der Instanz
echo "Verknüpfe die neue Elastic IP mit der Instanz $SELECTED_INSTANCE..."
aws ec2 associate-address --instance-id "$SELECTED_INSTANCE" --allocation-id "$NEW_ALLOCATION"

# Prüfe, ob die Verknüpfung erfolgreich war
if [ $? -eq 0 ]; then
  echo "Die Elastic IP wurde erfolgreich mit der Instanz $SELECTED_INSTANCE verknüpft."
else
  echo "Fehler beim Verknüpfen der Elastic IP mit der Instanz."
  exit 1
fi

# Schritt 4: Zeige die öffentliche IP der neuen Elastic IP an
NEW_PUBLIC_IP=$(aws ec2 describe-addresses \
  --allocation-ids "$NEW_ALLOCATION" \
  --query "Addresses[0].PublicIp" --output text)

echo "Die Elastic IP der Instanz $SELECTED_INSTANCE lautet: $NEW_PUBLIC_IP"
