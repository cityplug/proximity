#!/bin/bash

# Ubuntu (unifi.cityplug.co.uk) setup script.

# --- Remove Bloatware
echo "#  ---  Removing Bloatware  ---  #"
apt update && apt full-upgrade -y
apt-get autoremove && apt-get autoclean -y

# --- Change root password
echo "#  ---  Change root password  ---  #"
passwd root
echo "#  ---  Add user password  ---  #"
adduser focal

# --- Install Packages
echo "#  ---  Installing New Packages  ---  #"
apt install ca-certificates -y
apt install net-tools -y
apt install curl -y
apt install wget -y
apt install unattended-upgrades -y
apt install letsencrypt -y
apt install ufw -y

# --- Addons
echo "#  ---  Running Addons  ---  #"
hostnamectl set-hostname unifi.cityplug.co.uk

rm -rf /etc/update-motd.d/* && rm -rf /etc/motd
mv /opt/proximity/ID_101/10-uname /etc/update-motd.d/ && chmod +x /etc/update-motd.d/10-uname
usermod -aG sudo focal
dpkg-reconfigure tzdata
dpkg-reconfigure --priority=low unattended-upgrades

echo "#  ---  Installing Unifi  ---  #"
wget https://get.glennr.nl/unifi/install/unifi-7.2.94.sh && bash unifi-7.2.94.sh

wget https://raw.githubusercontent.com/cityplug/ID_101/main/unifi_ssl_import.sh -O /usr/local/bin/unifi_ssl_import.sh
chmod +x /usr/local/bin/unifi_ssl_import.sh

# Automate renewal script
echo "
0 * * */2 * root letsencrypt renew
5 * * */2 * root unifi_ssl_import.sh
0 0 1 * * sudo apt update && sudo apt dist-upgrade -y
0 0 1 */2 * root reboot" >>/etc/crontab

# --- Firewall Rules 
ufw allow 3478/udp
ufw allow 10001/udp
ufw allow 8080
ufw allow 8443
ufw allow 1900/udp
ufw allow 6789
ufw allow 5514/udp
#ufw allow from 192.168.50.*** to any port 22
ufw allow 80
ufw allow 443
ufw deny 22
ufw logging on

echo "#  ---  COMPLETED | REBOOT SYSTEM  ---  #"
reboot