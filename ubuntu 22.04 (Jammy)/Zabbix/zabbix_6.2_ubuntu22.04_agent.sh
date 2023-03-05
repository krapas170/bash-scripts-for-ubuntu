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
# Execute command:    wget "https://raw.githubusercontent.com/krapas170/bash-scripts-for-ubuntu/main/ubuntu%2022.04%20(Jammy)/Zabbix/zabbix_6.2_ubuntu22.04_agent.sh" && bash zabbix_6.2_ubuntu22.04_agent.sh

RED='\033[0;31m'
GREEN='\033[0;32m'
GRAY='\033[1;30m'
NC='\033[0m' # No Color

if [ $(id -u) -ne 0 ]; then
    printf "${NC}%s${RED}%s${NC}\n" "This script must be run as root. Please enter your password to continue then restart the script with " "bash /root/zabbix_6.2_ubuntu22.04_agent.sh"
    sudo mv zabbix_6.2_ubuntu22.04_agent.sh /root/zabbix_6.2_ubuntu22.04_agent.sh
    sudo "$0" "$@"
    exit
fi

cd

# Function to validate IP address syntax
function validate_ip() {
  local  ip=$1
  local  stat=1

  if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
    OIFS=$IFS
    IFS='.'
    ip=($ip)
    IFS=$OIFS
    [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
    stat=$?
  fi
  return $stat
}

# Read informations from user
while true; do
  printf "${GREEN}Enter IP of zabbix-server:${NC} ${GRAY}(e.g. 127.0.0.1)${NC} "
  read IP_ZABBIX_SERVER
  if validate_ip "$IP_ZABBIX_SERVER"; then
    break
  else
    echo "Invalid IP address. Please try again."
  fi
done

printf "${GREEN}Enter hostname of this host:${NC} ${GRAY}(e.g. localhost)${NC} "
read HOSTNAME

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
sed -i "s/Server=127.0.0.1/Server=$IP_ZABBIX_SERVER/g" /etc/zabbix/zabbix_agent2.conf
sed -i "s/ServerActive=127.0.0.1/ServerActive=$IP_ZABBIX_SERVER/g" /etc/zabbix/zabbix_agent2.conf
sed -i "s/Hostname=Zabbix server/Hostname=$HOSTNAME/g" /etc/zabbix/zabbix_agent2.conf

# Enable and start services
echo "Zabbix agent2 is now installed. Please wait 5 seconds."
sleep 5s
systemctl restart zabbix-agent2
systemctl enable zabbix-agent2

# Show Zabbix URL
echo "Zabbix agent2 is installed and running. You can add this server via your Zabbix server with the following settings:"

# Display host configuration
IP_HOST=$(hostname -I | awk '{print $1}')

printf "\n        \033[1m\033[4mHost configuration:\033[0m\n"
printf "${RED}%-20s ${NC}%s\n" "Hostname:" "$HOSTNAME"
printf "${RED}%-20s ${NC}%s\n" "Templates:" "Linux by Zabbix agent"
printf "${RED}%-20s ${NC}%s${GRAY}%s${NC}\n" "Hostgroups:" "Linux servers " "or something else"
printf "${RED}%-20s${NC}\n" "Interfaces:"
printf "${GREEN}%-20s %-20s${NC}\n" "Typ" "IP-address"
printf "%-20s %-20s\n" "Agent" "$IP_HOST"
echo


# Cleanup installation script
rm zabbix*
