wget http://prdownloads.sourceforge.net/webadmin/webmin_1.930_all.deb
dpkg --install webmin_1.930_all.deb
sudo apt-get -f install -y
sudo rm webmin_1.930_all.deb
sudo ufw allow 10000
echo "referers=127.0.0.1 $2 $1.$2" >> /etc/webmin/config
