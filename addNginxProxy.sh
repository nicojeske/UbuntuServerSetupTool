echo "Adding Proxy for $1 from $2 to localhost port $3"
sudo tee -a /etc/nginx/sites-enabled/$1 > /dev/null <<EOT


server {
 listen 443 ssl;
 server_name $2.$1;
    ssl_certificate /etc/letsencrypt/live/$1/fullchain.pem; # managed by Certbot
    ssl_certificate_key /etc/letsencrypt/live/$1/privkey.pem; # managed by Certbot
  include /etc/letsencrypt/options-ssl-nginx.conf;
  ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;
  root /var/www/;
  index index.html;
  location / {
    #try_files \$uri \$uri/ =404;
    proxy_pass https://127.0.0.1:$3;
  }
}
EOT
