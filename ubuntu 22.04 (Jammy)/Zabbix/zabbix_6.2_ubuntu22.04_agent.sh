#!/bin/bash
#
# Name:           zabbix_6.2_ubuntu22.04_agent.sh
# Description:    This script installs only the agent of Zabbix 6.2 on a Linux Ubuntu 22.04 system.
# Author:         Pascal Kray
# Author URI:     https://krapas170.github.io/
# GitHub URI:     https://github.com/krapas170/
# License:        GPL v3 or later
# License URI:    https://www.gnu.org/licenses/gpl-3.0.de.html
#
#
# Execute command:    wget "https://raw.githubusercontent.com/krapas170/bash-scripts-for-ubuntu/main/ubuntu%2022.04%20(Jammy)/Zabbix/zabbix_6.2_ubuntu22.04_agent.sh" && sh zabbix_6.2_ubuntu22.04_agent.sh


# Read informations from user
read -p "Enter IP of zabbix-server: " IP_ZABBIX_SERVER
read -p "Enter hostname of this host: " HOSTNAME

# Update system
apt update
apt upgrade -y

# Zabbix repository
wget https://repo.zabbix.com/zabbix/6.2/ubuntu/pool/main/z/zabbix-release/zabbix-release_6.2-4%2Bubuntu22.04_all.deb
dpkg -i zabbix-release_6.2-4+ubuntu22.04_all.deb
apt update

# Install Zabbix agent 2
apt install zabbix-agent2 zabbix-agent2-plugin-*

# Edit the agent2 configuration file
sed -i "s/# Server=127.0.0.1/Server=$IP_ZABBIX_SERVER/g" /etc/zabbix/zabbix_agent2.conf
sed -i "s/# ServerActive=127.0.0.1/ServerActive=$IP_ZABBIX_SERVER/g" /etc/zabbix/zabbix_agent2.conf
sed -i "s/# Hostname=Zabbix server/Server=$HOSTNAME/g" /etc/zabbix/zabbix_agent2.conf

# Enable and start services
echo "Zabbix agent2 is now installed. Please wait 5 seconds."
sleep 5s
systemctl restart zabbix-agent2
systemctl enable zabbix-agent2

# Show Zabbix URL
echo "Zabbix agent2 is installed and running. You can add this server via your Zabbix server"
