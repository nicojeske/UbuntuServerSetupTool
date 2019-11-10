sudo tee /etc/nginx/sites-enabled/$1 > /dev/null <<EOT
server {
 listen 80;
 listen [::]:80;
 server_name *.$1;
 return 301 https://\$host\$request_uri;
}

server {
 listen 443 ssl;
 server_name *.$1;
    ssl_certificate /etc/letsencrypt/live/$1/fullchain.pem; # managed by Certbot
    ssl_certificate_key /etc/letsencrypt/live/$1/privkey.pem; # managed by Certbot
 include /etc/letsencrypt/options-ssl-nginx.conf;
  ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;
  root /var/www/;
  index index.html;
  location / {
    try_files \$uri \$uri/ =404;
  }

}
EOT
sudo nginx -t
sudo systemctl restart nginx
