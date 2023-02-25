#!/bin/bash
#
# Name:           zabbix_6.2_ubuntu22.04_server_frontend_agent.sh
# Description:    This script installs the server, frontend, and agent of Zabbix 6.2 on a Linux Ubuntu 22.04 system. 
#                 Additionally, the script installs and configures Apache, MySQL, and PHP.
# Author:         Pascal Kray
# Author URI:     https://krapas170.github.io/
# GitHub URI:     https://github.com/krapas170/
# License:        GPL v3 or later
# License URI:    https://www.gnu.org/licenses/gpl-3.0.de.html


# Installiere MySQL
sudo apt-get install mysql-server -y

# Warte auf Eingabeaufforderung für MySQL-Root-Passwort
read -s -p "Enter MySQL root password: " MYSQL_ROOT_PASSWORD

# Konfiguriere MySQL
echo -e "$MYSQL_ROOT_PASSWORD\n$MYSQL_ROOT_PASSWORD\ny\ny\ny\ny\n" | sudo mysql_secure_installation

# Zabbix repository
wget https://repo.zabbix.com/zabbix/6.2/ubuntu/pool/main/z/zabbix-release/zabbix-release_6.2-4%2Bubuntu22.04_all.deb
dpkg -i zabbix-release_6.2-4+ubuntu22.04_all.deb
apt update

# Install Zabbix server, frontend, agent, Apache, and MySQL
apt install zabbix-server-mysql zabbix-frontend-php zabbix-apache-conf zabbix-sql-scripts zabbix-agent mysql-server apache2 -y

# Ask for Zabbix MySQL password
echo "Please enter a password for the Zabbix MySQL user:"
read -s -p zabbix_password

# Create initial database
mysql -uroot -e "create database zabbix character set utf8mb4 collate utf8mb4_bin;"
mysql -uroot -e "create user zabbix@localhost identified by '$zabbix_password';"
mysql -uroot -e "grant all privileges on zabbix.* to zabbix@localhost;"
mysql -uroot -e "set global log_bin_trust_function_creators = 1;"

# Import initial schema and data
zcat /usr/share/zabbix-sql-scripts/mysql/server.sql.gz | mysql -u zabbix -p"$zabbix_password" zabbix

# Configure the database for Zabbix server
sed -i "s/# DBPassword=/DBPassword=$zabbix_password/g" /etc/zabbix/zabbix_server.conf

# Enable and start services
systemctl enable zabbix-server zabbix-agent apache2 mysql
systemctl start zabbix-server zabbix-agent apache2 mysql

# Show Zabbix URL
echo "Zabbix is installed and running. You can access it at http://<server-ip>/zabbix"
