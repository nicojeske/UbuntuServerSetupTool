apt-get update -y
apt-get upgrade -y
wget https://download.docker.com/linux/ubuntu/gpg
apt-key add gpg
sudo tee -a /etc/apt/sources.list.d/docker.list > /dev/null <<EOT
deb [arch=amd64] https://download.docker.com/linux/ubuntu xenial stable
EOT
apt-get update -y
apt-get install docker-ce -y
docker pull portainer/portainer
mkdir /opt/portainer /data
docker run -d -p 9000:9000 --restart always -v /var/run/docker.sock:/var/run/docker.sock -v /opt/portainer:/data portainer/portainer
