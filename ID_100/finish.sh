#!/bin/bash
docker-compose --version && docker --version

systemctl stop systemd-resolved
systemctl disable systemd-resolved

cd /opt/proximity/ID_100/localdomain
echo
docker-compose up -d

docker run -d -p 8000:8000 -p 9000:9000 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v /docker/portainer/data:/data portainer/portainer-ce:latest
docker run -d -p 85:8080 --name homer --restart=always -v /docker/homer/assets:/www/assets b4bz/homer:latest
# --- Docker Service
docker ps

# --- Build Homer
docker stop homer
rm -rf /docker/homer/*
mv /opt/proximity/ID_100/homer/assets /docker/homer/assets
docker start homer

echo "#  ---  COMPLETED | REBOOT SYSTEM  ---  #"
exit


