#!/bin/bash

# Raspbian (docker virtual machine) setup script.

# --- Remove Bloatware
echo "#  ---  Removing Bloatware  ---  #"
apt update && apt full-upgrade -y

# --- Initialzing docker
hostnamectl set-hostname docker.localdomain
hostnamectl set-hostname "Docker Virtual Machine" --pretty

# --- Install Packages
echo "#  ---  Installing New Packages  ---  #"
apt install unattended-upgrades -y
apt install curl -y
apt install ufw -y
apt install ca-certificates -y

# --- Install Docker
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# --- Install Docker-Compose
apt update && apt install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y

wget https://github.com/docker/compose/releases/download/v2.14.0/docker-compose-linux-x86_64 -O /usr/local/bin/docker-compose

chmod +x /usr/local/bin/docker-compose && apt install docker-compose -y

systemctl enable docker
docker-compose --version && docker --version

# --- Create and allocate swap
echo "#  ---  Creating 2GB swap file  ---  #"
fallocate -l 2G /swapfile
chmod 600 /swapfile
mkswap /swapfile && swapon /swapfile
# --- Add swap to the /fstab file & Verify command
sh -c 'echo "/swapfile none swap sw 0 0" >> /etc/fstab' && cat /etc/fstab
sh -c 'echo "apt autoremove -y" >> /etc/cron.monthly/autoremove'
# --- Make file executable
chmod +x /etc/cron.monthly/autoremove
echo "#  ---  2GB swap file created | SYSTEM REBOOTING  ---  #"

# --- Firewall Rules 
ufw deny 22
ufw logging on

# --- Addons
echo "
net.ipv4.ip_forward = 1
net.ipv6.conf.all.forwarding = 1" >> /etc/sysctl.conf
sysctl -p

echo "#  ---  Running Addons  ---  #"
rm -rf /etc/update-motd.d/* && rm -rf /etc/motd
mv /opt/proximity/ID_100/10-uname /etc/update-motd.d/ && chmod +x /etc/update-motd.d/10-uname

# --- Change root password
echo "#  ---  Change root password  ---  #"
passwd root
echo "#  ---  Root password changed  ---  #"

# --- Docker Service
docker-compose --version && docker --version

cd /opt/proximity/ID_100/localdomain
echo
docker-compose up -d

docker run -d -p 8000:8000 -p 9000:9000 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v /docker/portainer/data:/data portainer/portainer-ce:latest
docker run -d -p 85:8080 --name homer --restart=always -v /docker/homer/assets:/www/assets b4bz/homer:latest

docker ps

# --- Build Homer
docker stop homer
rm -rf /docker/homer/*
mv /opt/proximity/ID_100/homer/assets /docker/homer/assets
docker start homer

echo "#  ---  COMPLETED | REBOOT SYSTEM  ---  #"
reboot