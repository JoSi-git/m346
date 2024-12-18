#!/bin/bash
set -e  # Beendet das Skript bei Fehlern

# Variablen definieren
source /home/ubuntu/variables.sh

# Paketliste aktualisieren
echo "Paketliste wird aktualisiert..."
sudo apt update -y

# Apache2 installieren
echo "Apache2 wird installiert..."
sudo apt install apache2 -y

# Apache-Dienst starten
echo "Apache2-Dienst wird gestartet..."
sudo systemctl start apache2
sudo systemctl enable apache2

# PHP installieren
sudo apt install php libapache2-mod-php php-mysql -y

# MYSQL-Client installieren und Verbindung testen
sudo apt install mysql-client -y
echo "Verbindung zur MySQL-Datenbank wird überprüft..."
mysql -h "$PUBLIC_IP1" -u "$DB_USER" -p"$DB_PASSWORD"

# Verbindungsergebnis prüfen
if [ $? -eq 0 ]; then
    echo "Erfolgreich mit der MySQL-Datenbank verbunden!"
else
    echo "Fehler: Verbindung zur MySQL-Datenbank fehlgeschlagen."
fi

## WordPress installieren
sudo mkdir -p /var/www/html/wordpress/src
sudo mkdir -p /var/www/html/wordpress/blog
cd /var/www/html/wordpress/src
sudo wget https://wordpress.org/latest.tar.gz
sudo tar -xvf latest.tar.gz
sudo mv latest.tar.gz wordpress-`date "+%Y-%m-%d"`.tar.gz
sudo mv wordpress/* ../blog/
sudo chown -R www-data:www-data /var/www/html/wordpress/blog

# WordPress konfigurieren

WP_SECURE_SALTS="$(curl -s https://api.wordpress.org/secret-key/1.1/salt/)"

WP_CONFIG_FILE=/var/www/html/wordpress/blog/wp-config.php
cat > "${WP_CONFIG_FILE}" <<EOF
<?php
// ** MySQL-Einstellungen ** //
/** Der Name der Datenbank für WordPress */
define( 'DB_NAME', '${DB_NAME}' );

/** MySQL-Datenbank-Benutzername */
define( 'DB_USER', '${DB_USER}' );

/** MySQL-Datenbank-Passwort */
define( 'DB_PASSWORD', '${DB_PASSWORD}' );

/** MySQL-Hostname */
define( 'DB_HOST', '${PUBLIC_IP1}' );

/** Zeichensatz der Datenbank, der zum Erstellen der Datenbanktabellen verwendet wird. */
define( 'DB_CHARSET', 'utf8' );

/** Der Kollationstyp der Datenbank. */
define( 'DB_COLLATE', '' );

/** Diverse weitere Einstellungen */
${WP_SECURE_SALTS}
/**#@-*/
\$table_prefix = 'wp_';
define( 'WP_DEBUG', false );

/** Der absolute Pfad zum WordPress-Verzeichnis. */
if ( ! defined( 'ABSPATH' ) ) {
    define( 'ABSPATH', __DIR__ . '/' );
}

/** Initialisiert WordPress-Variablen und eingebundene Dateien. */
require_once ABSPATH . 'wp-settings.php';
EOF

# Berechtigung anpassen
sudo chown -R www-data:www-data "${WP_CONFIG_FILE}"

# Apache-Konfigurationsdatei
APACHE_CONF_FILE="/etc/apache2/sites-available/000-default.conf"

# Apache-Konfiguration anpassen, um WordPress als DocumentRoot festzulegen
echo "Apache-Konfiguration wird angepasst, um WordPress als DocumentRoot zu verwenden..."
sudo sed -i "s|DocumentRoot /var/www/html|DocumentRoot /var/www/html/wordpress/blog|" "${APACHE_CONF_FILE}"

# Sicherstellen, dass keine Standard-Apache-Webseite angezeigt wird
echo "Entfernen der Standard-Apache-Webseite..."
sudo rm -f /var/www/html/index.html

# Apache neu starten, um die Änderungen zu übernehmen
echo "Apache wird neu gestartet..."
sudo systemctl restart apache2
