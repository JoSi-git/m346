# AWS EC2 Instanzmanagement

Dieses Dokument enthält grundlegende Befehle zur Verwaltung von AWS EC2-Instanzen. Die folgenden Anweisungen helfen Ihnen, wichtige Informationen zu Instanzen abzurufen und Instanzen sicher herunterzufahren.

## Befehle

### Instanzen herunterfahren

```bash
aws ec2 terminate-instances --instance-ids "instance ID"
```

# Kommentar:
# Dieser Befehl beendet eine oder mehrere EC2-Instanzen anhand ihrer Instanz-IDs.
# Stellen Sie sicher, dass Sie die "instance ID" durch die tatsächliche ID der Instanz ersetzen, die Sie beenden möchten.
# Warnung: Das Beenden einer Instanz führt zum Verlust aller nicht persistierten Daten auf dieser Instanz.

### Wichtige Instanzinformationen anzeigen

```bash
aws ec2 describe-instances --query "Reservations[*].Instances[*].{InstanceId:InstanceId, PublicIP:PublicIpAddress, State: State.Name}"
```

# Kommentar:
# Mit diesem Befehl werden Details zu allen laufenden Instanzen abgerufen.
# Die Ausgabe zeigt die Instanz-ID, die öffentliche IP-Adresse und den aktuellen Status jeder Instanz.
# Der "--query" Parameter filtert die Ergebnisse für eine klarere Darstellung.
