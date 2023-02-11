#!/bin/bash

systemctl stop systemd-resolved
systemctl disable systemd-resolved

# --- Docker Service
docker-compose --version && docker --version

cd /opt/proximity/ID_102/localdomain
echo
docker-compose up -d

docker run -d -p 9001:9001 --name portainer_agent --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v /var/lib/docker/volumes:/var/lib/docker/volumes portainer/agent:latest

docker ps

echo "# --- Enter pihole user password --- #"
docker exec -it pihole pihole -a -p
echo "#  ---  COMPLETED | REBOOT SYSTEM  ---  #"
exit


