#!/bin/bash

# Variablen für MySQL Konfiguration
MYSQL_ROOT_PASS="root_passwort"
MYSQL_USER="wp_user"
MYSQL_USER_PASS="wp_user_passwort"
MYSQL_DB="wordpress_db"
MYSQL_HOST="0.0.0.0"  # Zum Zugreifen von allen IP-Adressen

# Update des Systems
echo "System wird aktualisiert..."
sudo apt update && sudo apt upgrade -y

# MySQL installieren (falls nicht bereits installiert)
echo "MySQL wird installiert..."
sudo apt install mysql-server ufw -y

# MySQL ohne Eingabe sichern
echo "MySQL wird gesichert..."
sudo mysql -e "UPDATE mysql.user SET authentication_string=PASSWORD('$MYSQL_ROOT_PASS') WHERE User='root';"
sudo mysql -e "FLUSH PRIVILEGES;"
sudo mysql -e "DELETE FROM mysql.user WHERE User='';"
sudo mysql -e "DROP DATABASE IF EXISTS test;"
sudo mysql -e "FLUSH PRIVILEGES;"

# MySQL-Server so konfigurieren, dass er von anderen Servern zugänglich ist
echo "MySQL-Konfiguration anpassen..."
sudo sed -i "s/^bind-address.*/bind-address = $MYSQL_HOST/" /etc/mysql/mysql.conf.d/mysqld.cnf

# MySQL neu starten, um die Änderungen anzuwenden
echo "MySQL-Server wird neu gestartet..."
sudo systemctl restart mysql

# Datenbank und Benutzer erstellen
echo "Datenbank und Benutzer werden erstellt..."
sudo mysql -u root -p$MYSQL_ROOT_PASS <<EOF
CREATE DATABASE $MYSQL_DB;
CREATE USER '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_USER_PASS';
GRANT ALL PRIVILEGES ON $MYSQL_DB.* TO '$MYSQL_USER'@'%';
FLUSH PRIVILEGES;
EOF

# Firewall anpassen, um den MySQL-Port freizugeben (optional)
echo "Firewall wird angepasst..."
if command -v ufw >/dev/null 2>&1; then
    sudo ufw allow from any to any port 3306 proto tcp
else
    echo "Firewall-Tool 'ufw' nicht gefunden, Firewall-Regel übersprungen."
fi

# MySQL-Status überprüfen
echo "Überprüfen des MySQL-Status..."
sudo systemctl status mysql

echo "MySQL-Server wurde erfolgreich eingerichtet!"
