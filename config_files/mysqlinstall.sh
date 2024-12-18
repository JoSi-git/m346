#!/bin/bash
set -e  # Beendet das Skript bei Fehlern

# Variablen definieren
source /home/ubuntu/variables.sh

# Update die Paketliste
echo "Updating package list..."
sudo apt update -y
sudo apt install mysql-server -y

# MySQL Root Passwort und wpadmin Passwort
MYSQL_USER="root"
MYSQL_ROOT_PASSWORD="Riethuesli>12345"
MYSQL_WP_USER="wpadmin"
MYSQL_WP_ADMIN_USER_PASSWORD="Riethuesli>12345"

# MySQL Sicherung und Konfiguration
mysql_secure_installation -u root --password="${MYSQL_ROOT_PASSWORD}" --use-default

# MySQL Benutzer und Datenbank erstellen
mysql -u root --password="${MYSQL_ROOT_PASSWORD}" <<EOF
CREATE DATABASE IF NOT EXISTS wordpress;
CREATE USER 'wpadmin'@'%' IDENTIFIED BY '${MYSQL_WP_ADMIN_USER_PASSWORD}';
GRANT ALL PRIVILEGES ON wordpress.* TO 'wpadmin'@'%';
FLUSH PRIVILEGES;
EOF

# Konfiguration für Remote-Verbindungen
echo "bind-address = $PUBLIC_IP1" >> /etc/mysql/mysql.conf.d/mysqld.cnf
sudo systemctl restart mysql.service
