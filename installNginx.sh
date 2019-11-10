sudo apt update
sudo apt install nginx
sudo ufw enable
sudo ufw allow 'Nginx Full'
sudo sed -i 's/# server_names_hash_bucket_size 64/server_names_hash_bucket_size 64/g' /etc/nginx/nginx.conf
