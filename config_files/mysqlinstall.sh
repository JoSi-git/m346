#!/bin/bash
set -e

# variables
source /home/ubuntu/variables.sh

# Install MySQL Server
apt update -y
apt install mysql-server -y

# Create Database and DB User
mysql -e "CREATE DATABASE $DB_NAME;"
mysql -e "CREATE USER '$DB_USER'@'%' IDENTIFIED BY '$DB_PASSWORD';"
mysql -e "GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'%';"
mysql -e "FLUSH PRIVILEGES;"

mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY 'root_password';"

# MySQL config konfigurieren
sed -i "s/bind-address.*/bind-address=0\.0\.0\.0/g" /etc/mysql/mysql.conf.d/mysqld.cnf
sed -i "s/mysqlx-bind-address.*/mysqlx-bind-address=0\.0\.0\.0/g" /etc/mysql/mysql.conf.d/mysqld.cnf

# Restart MySQL service
systemctl restart mysql