echo ""
echo "Installing cerbot"
sudo apt-get update
sudo apt-get install software-properties-common -y
sudo add-apt-repository universe -y
sudo add-apt-repository ppa:certbot/certbot -y
sudo apt-get update
sudo apt-get install certbot python-certbot-nginx -y
sudo apt-get install python3-certbot-dns-cloudflare -y
mkdir ~/.secrets
mkdir ~/.secrets/certbot
rm ~/.secrets/certbot/cloudflare.ini
echo "# Cloudflare API credentials used by Certbot" >> ~/.secrets/certbot/cloudflare.ini
echo "dns_cloudflare_email = $1" >> ~/.secrets/certbot/cloudflare.ini
echo "dns_cloudflare_api_key = $2" >> ~/.secrets/certbot/cloudflare.ini
chmod 600 ~/.secrets/certbot/cloudflare.ini
sudo certbot certonly --dns-cloudflare --dns-cloudflare-credentials ~/.secrets/certbot/cloudflare.ini -d *.$3 -d $3 -i nginx
