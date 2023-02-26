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

# Update system
apt update
apt upgrade -y

# Install MySQL
sudo apt-get install mysql-server apache2 php libapache2-mod-php -y

# Prompt for MySQL root/Zabbix password
read -p "Enter MySQL root password: " MYSQL_ROOT_PASSWORD
read -p "Enter MySQL zabbix password: " MYSQL_ZABBIX_PASSWORD

# Configure MySQL
mysql -e "alter user 'root'@'localhost' identified with mysql_native_password by '$MYSQL_ROOT_PASSWORD';"
echo -e "$MYSQL_ROOT_PASSWORD\n$MYSQL_ROOT_PASSWORD\ny\ny\ny\ny\n" | sudo mysql_secure_installation

# Zabbix repository
wget https://repo.zabbix.com/zabbix/6.2/ubuntu/pool/main/z/zabbix-release/zabbix-release_6.2-4%2Bubuntu22.04_all.deb
dpkg -i zabbix-release_6.2-4+ubuntu22.04_all.deb
apt update

# Install Zabbix server, frontend, agent, Apache, and MySQL
apt install zabbix-server-mysql zabbix-frontend-php zabbix-apache-conf zabbix-sql-scripts zabbix-agent mysql-server apache2 -y

# Create initial database
mysql -u root -p$MYSQL_ROOT_PASSWORD -e "create database zabbix character set utf8mb4 collate utf8mb4_bin;"
mysql -u root -p$MYSQL_ROOT_PASSWORD -e "create user zabbix@localhost identified with mysql_native_password by '$MYSQL_ZABBIX_PASSWORD';"
mysql -u root -p$MYSQL_ROOT_PASSWORD -e "grant all privileges on zabbix.* to zabbix@localhost;"
mysql -u root -p$MYSQL_ROOT_PASSWORD -e "set global log_bin_trust_function_creators = 1;"

# Import initial schema and data
zcat /usr/share/zabbix-sql-scripts/mysql/server.sql.gz | mysql -u zabbix -p"$MYSQL_ZABBIX_PASSWORD" zabbix

# Configure the database for Zabbix server
sed -i "s/# DBPassword=/DBPassword=$MYSQL_ZABBIX_PASSWORD/g" /etc/zabbix/zabbix_server.conf

# Enable and start services
echo "Zabbix is now installed. Please wait 5 seconds."
sleep 5s
systemctl enable zabbix-server zabbix-agent apache2 mysql
systemctl start zabbix-server zabbix-agent apache2 mysql

# Show Zabbix URL
echo "Zabbix is installed and running. You can access it at http://<server-ip>/zabbix"
