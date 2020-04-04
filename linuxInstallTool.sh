#!/bin/bash
if [[ "$EUID" == 0 ]]; then
  echo "Welcome to the LinuxServerInstallTool."
  echo "Installing dependencies..."
else
  sudo -k
  if sudo true; then
    echo "Welcome to the LinuxServerInstallTool."
    echo "Installing dependencies..."
  else
    echo "You can only run this script with sudo..."
    exit 1
  fi
fi

apt-get update -q -y
apt-get install -q -y dialog
mkdir /var/linuxsetuptool
selectedInMainMenu=nothing
selectedInInstallMenu=nothing
selectedInContainerMenu=nothin
nginxInstalled=1

############################################
##### MENUS
############################################

mainMenu() {
  selectedInMainMenu=$(
    dialog --menu \
    "Select action..." 0 0 0 \
    "Install" "" \
    "Container" "" \
    "NginxProxy" "" \
    "Close" "" 3>&1 1>&2 2>&3
  )
  dialog --clear
  clear

  mainMenuSwitch
}

installMenu() {
  selectedInInstallMenu=$(
    dialog --checklist "Software to install..." 0 0 0 \
    "Webmin" "" off \
    "ZSH" "" off \
    "NginxWithSSL" "" off \
    "Docker" "" off 3>&1 1>&2 2>&3
  )
  dialog --clear
  clear

  installSwitch "$selectedInInstallMenu"
}

containerMenu() {
  selectedInContainerMenu=$(
    dialog --checklist "Containers to install..." 0 0 0 \
    "Portainer" "" off \
    "Statping" "" off \
    "Teamspeak" "" off \
    "Sinusbot" "" off \
    "Nextcloud" "" off \
    "Heimdall" "" off \
    "Duplicati" "" off \
    "Watchtower" "" off 3>&1 1>&2 2>&3
  )
  dialog --clear
  clear

  containerSwitch "$selectedInContainerMenu"
}

############################################
##### MAIN MENU SWITCH
############################################

mainMenuSwitch() {
  case $selectedInMainMenu in
  'Install')
    installMenu
    ;;
  'Container')
    if ! which nginx >/dev/null 2>&1; then
      nginxInstalled=0
      dialog --msgbox "Nginx is not installed. Containers won't be automatically put behind a reverse proxy" 0 0
    fi
    if ! which docker >/dev/null 2>&1; then
      dialog --msgbox "You must first install Docker." 0 0
      mainMenu
      return 1
    fi

    containerMenu
    ;;
  'NginxProxy')
    if ! which nginx >/dev/null 2>&1; then
      nginxInstalled=0
      dialog --msgbox "Nginx is not installed!" 0 0
      mainMenu
      return 1
    else
      generateProxyBasedOnUserInput
    fi
    ;;
  esac
}

############################################
##### INSTALLER FUNCTIONS
############################################

installSwitch() {
  for ToInstall in $1; do
    case $ToInstall in
    'Webmin')
      installWebmin
      ;;
    'ZSH')
      installZSH
      ;;
    'Docker')
      installDockerAndDockerCompose
      ;;
    'NginxWithSSL')
      cloudflare_email=$(dialog --inputbox "Cloudflare email" 0 0 "" 3>&1 1>&2 2>&3)
      cloudflare_api_key=$(dialog --inputbox "Cloudflare API-KEY" 0 0 "" 3>&1 1>&2 2>&3)
      domain=$(dialog --inputbox "Domain (example: nicojeske.de)" 0 0 "" 3>&1 1>&2 2>&3)

      installNginxWithSSL "$cloudflare_email" "$cloudflare_api_key" "$domain"
      ;;
    esac
  done

  mainMenu
}

installWebmin() {
  steps=4

  progressBar "$(steps 1 $steps)" "Adding webmin Repository"
  echo "deb http://download.webmin.com/download/repository sarge contrib" >>/etc/apt/sources.list.d/webmin.list
  echo "deb http://webmin.mirror.somersettechsolutions.co.uk/repository sarge contrib" >>/etc/apt/sources.list.d/webmin.list
  curl http://www.webmin.com/jcameron-key.asc | sudo apt-key add -
  progressBar "$(steps 2 $steps)" "apt update"
  apt-get update -q -y
  progressBar "$(steps 3 $steps)" "Install webmin and usermin"
  apt-get install -q -y webmin usermin
  /etc/init.d/webmin restart
  progressBar "$(steps 4 $steps)" "Webmin installed"
}

installZSH() {
  steps=5

  progressBar "$(steps 1 $steps)" "Installing ZSH"
  apt-get install git -q -y
  apt-get install zsh -q -y

  dialog --msgbox "Oh my ZSH will ask you if you want to set ZSH to your default shell. answer this with y and then exit the zsh shell with 'exit' to continue the setup tool" 0 0
  dialog --clear
  clear
  progressBar "$(steps 2 $steps)" "Installing Oh-My-Zsh"
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

  progressBar "$(steps 3 $steps)" "Appliying custom theme"
  sed -i 's/robbyrussell/agnoster/g' $HOME/.zshrc
  sed -i 's/prompt_segment blue $CURRENT_FG/prompt_segment red white/g' ~/.oh-my-zsh/themes/agnoster.zsh-theme
  sed -i 's/prompt_segment black/prompt_segment blue/g' ~/.oh-my-zsh/themes/agnoster.zsh-theme

  progressBar "$(steps 4 $steps)" "Install Syntax-Highlighting"
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$HOME/.zsh-syntax-highlighting" --depth 1
  apt-get install -y locales
  locale-gen en_US.UTF-8
  echo "source $HOME/.zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >>"$HOME/.zshrc"

  progressBar "$(steps 5 $steps)" "ZSH installed"
}

installDockerAndDockerCompose() {
  steps=7
  progressBar "$(steps 0 $steps)" "Remove existing docker version"
  apt-get -q -y remove docker docker-engine docker.io containerd runc

  progressBar "$(steps 1 $steps)" "Install Dependencies"
  (
    apt-get install -q -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
  )

  progressBar "$(steps 3 $steps)" "Add Docker Repo"
  add-apt-repository \
  "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
     $(lsb_release -cs) \
     stable"

  progressBar "$(steps 4 $steps)" "apt update"
  apt-get update -q -y

  progressBar "$(steps 5 $steps)" "Install docker"
  apt-get install -q -y docker-ce docker-ce-cli containerd.io

  progressBar "$(steps 6 $steps)" "Install dockercompose"
  curl -L "https://github.com/docker/compose/releases/download/1.25.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  chmod +x /usr/local/bin/docker-compose

  groupadd docker
  usermod -aG docker $(whoami)

  progressBar "$(steps 7 $steps)" "Finished"
}

installNginxWithSSL() {
  steps=6

  progressBar "$(steps 0 $steps)" "Installing Nginx"
  apt install nginx -q -y

  progressBar "$(steps 1 $steps)" "Configure Firewall"
  ufw allow ssh
  echo "y" | ufw enable
  sudo ufw allow 'Nginx Full'

  progressBar "$(steps 2 $steps)" "Install Certbot"
  apt-get install software-properties-common -q -y
  add-apt-repository universe -y
  add-apt-repository ppa:certbot/certbot -y
  apt-get update -q -y
  apt-get install certbot python-certbot-nginx -q -y
  apt-get install python3-certbot-dns-cloudflare -q -y

  progressBar "$(steps 3 $steps)" "Generating SSL Certificate"
  mkdir ~/.secrets
  mkdir ~/.secrets/certbot
  rm ~/.secrets/certbot/cloudflare.ini
  echo "# Cloudflare API credentials used by Certbot" >>~/.secrets/certbot/cloudflare.ini
  echo "dns_cloudflare_email = $1" >>~/.secrets/certbot/cloudflare.ini
  echo "dns_cloudflare_api_key = $2" >>~/.secrets/certbot/cloudflare.ini
  chmod 600 ~/.secrets/certbot/cloudflare.ini
  certbot certonly --dns-cloudflare --dns-cloudflare-credentials ~/.secrets/certbot/cloudflare.ini --agree-tos --no-eff-email --email nico.jeske@gmail.com -d *.$3 -d $3 -i nginx

  progressBar "$(steps 4 $steps)" "Configure nginx"

  tee /etc/nginx/sites-enabled/$3 >/dev/null <<EOT
server {
 listen 80;
 listen [::]:80;
 server_name *.$3;
 return 301 https://\$host\$request_uri;
}

server {
 listen 443 ssl;
 server_name *.$3;
    ssl_certificate /etc/letsencrypt/live/$3/fullchain.pem; # managed by Certbot
    ssl_certificate_key /etc/letsencrypt/live/$3/privkey.pem; # managed by Certbot
 include /etc/letsencrypt/options-ssl-nginx.conf;
  ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;

  root /var/www/;
  index index.html;
  location / {
    try_files \$uri \$uri/ =404;
  }

}
EOT
  sed -i 's/# server_names_hash_bucket_size 64/server_names_hash_bucket_size 64/g' /etc/nginx/nginx.conf

  progressBar "$(steps 5 $steps)" "Reload Nginx"
  nginx -t
  /etc/init.d/nginx reload

  progressBar "$(steps 6 $steps)" "Finished"

}

#########################
###CONTAINER ACTIONS
#########################
containerSwitch() {
  for ToInstall in $1; do
    case $ToInstall in
    'Portainer') installPortainer ;;
    'Statping') installStatping ;;
    'Teamspeak') installTeamspeak ;;
    'Sinusbot') installSinusbot ;;
    'Nextcloud') installNextcloud ;;
    'Watchtower') installWatchtower ;;
    'Heimdall') installHeimdall ;;
    'Duplicati') installDuplicati ;;
    esac
  done
  #  mainMenu
}

installPortainer() {
  steps=2

  progressBar $(steps 0 $steps) "Create Volume for Portainer"
  docker volume create portainer_data

  port=$(askPort "External port for Portainer")
  clear

  progressBar $(steps 1 $steps) "Installing Portainer"
  docker run -d -p $port:9000 --name=portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer

  askForNginxProxy "Portainer" $port http
  progressBar $(steps 2 $steps) "Portainer installed"
}

installStatping() {
  (
    mkdir /var/linuxsetuptool/statping
    cd /var/linuxsetuptool/statping
    steps=3

    progressBar $(steps 0 $steps) "Setup installation of statping"
    rm /var/linuxsetuptool/statping/docker-compose.yml
    port=$(askPort "External port for Statping")
    clear

    progressBar $(steps 1 $steps) "Get and setup dockercompose for statping"
    wget https://raw.githubusercontent.com/statping/statping/master/docker-compose.yml
    replaceInFile "8080:8080" "$port:8080" docker-compose.yml
    echo "volumes:" >>docker-compose.yml
    echo " statping_data:" >>docker-compose.yml

    progressBar $(steps 2 $steps) "Installing statping"
    docker-compose up -d
    askForNginxProxy "Statping" $port http

    progressBar $(steps 3 $steps) "statping installed"
  )
}

installTeamspeak() {
  steps=3

  progressBar $(steps 1 $steps) "Install Teamspeak"
  docker run -d \
  -v teaspeak_files:/opt/teaspeak/files \
  -v teaspeak_db:/opt/teaspeak/database \
  -v teaspeak_certs:/opt/teaspeak/certs \
  -v teaspeak_logs:/opt/teaspeak/logs \
  -p 10011:10011 -p 30033:30033 -p 9987:9987 -p 9987:9987/udp \
  --restart=unless-stopped --name teaspeak eparlak/teaspeak:slim

  progressBar $(steps 2 $steps) "Allow ports"
  ufw allow 10011
  ufw allow 30033
  ufw allow 9987/udp

  progressBar $(steps 3 $steps) "Installed Teamspeak"
}

installSinusbot() {
  steps=2

  port=$(askPort "External port for Sinusbot")
  clear

  progressBar $(steps 1 $steps) "Install sinusbot"
  docker run -d -p $port:8087 \
  -v /opt/sinusbot/scripts:/opt/sinusbot/scripts \
  -v /opt/sinusbot/data:/opt/sinusbot/data \
  --name sinusbot \
  sinusbot/docker
  askForNginxProxy "Sinusbot" $port http

  progressBar $(steps 2 $steps) "Installed sinusbot"
}

installNextcloud() {
  (
    mkdir /var/linuxsetuptool/nextcloud
    cd /var/linuxsetuptool/nextcloud
    steps=3

    rm docker-compose.yml
    port=$(askPort "External port for Nextcloud")
    clear

    progressBar $(steps 1 $steps) "Setup docker-compose.yml"
    cat >>docker-compose.yml <<'EOF'
version: '2'

volumes:
  nextcloud:
  nextcloud_db:

services:
  db:
    image: mariadb
    command: --transaction-isolation=READ-COMMITTED --binlog-format=ROW
    restart: always
    volumes:
      - nextcloud_db:/var/lib/mysql
    environment:
      - MYSQL_ROOT_PASSWORD=nextcloudRoot
      - MYSQL_PASSWORD=nextcloudDb
      - MYSQL_DATABASE=nextcloud
      - MYSQL_USER=nextcloud

  app:
    image: nextcloud
    ports:
      - PORTTOKEN:80
    links:
      - db
    volumes:
      - nextcloud:/var/www/html
    restart: always
EOF
    replaceInFile "PORTTOKEN:80" "$port:80" docker-compose.yml
    progressBar $(steps 2 $steps) "Install Nextcloud"

    docker-compose -p nextcloud up -d
    askForNginxProxy "Nextcloud" $port http
    progressBar $(steps 3 $steps) "Installed nextcloud"
  )
}

installWatchtower() {
  steps=2
  progressBar $(steps 1 $steps) "Install watchtower"
  docker run -d \
  --name watchtower \
  -v /var/run/docker.sock:/var/run/docker.sock \
  containrrr/watchtower
  progressBar $(steps 2 $steps) "Installed watchtower"
}

installHeimdall() {
      mkdir /var/linuxsetuptool/heimdall
    cd /var/linuxsetuptool/heimdall
    steps=3

    rm docker-compose.yml
    port=$(askPort "External port for Heimdall")
    clear

    progressBar $(steps 1 $steps) "Setup docker-compose.yml"
    cat >>docker-compose.yml <<'EOF'
version: "2"
services:
  heimdall:
    image: linuxserver/heimdall
    container_name: heimdall
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Europe/London
    volumes:
      - /var/linuxsetuptool/heimdall/config:/config
    ports:
      - PORTTOKEN:443
    restart: unless-stopped
EOF
    replaceInFile "PORTTOKEN:443" "$port:443" docker-compose.yml
    progressBar $(steps 2 $steps) "Install Heimdall"

    docker-compose up -d
    askForNginxProxy "Heimdall" $port https
    progressBar $(steps 3 $steps) "Installed Heimdall"
}

installDuplicati() {
      mkdir /var/linuxsetuptool/duplicati
    cd /var/linuxsetuptool/duplicati
    steps=3

    rm docker-compose.yml
    port=$(askPort "External port for Duplicati")
    clear

    progressBar $(steps 1 $steps) "Setup docker-compose.yml"
    cat >>docker-compose.yml <<'EOF'
version: "2"
services:
  duplicati:
    image: linuxserver/duplicati
    container_name: duplicati
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Europe/London
      - CLI_ARGS= #optional
    volumes:
      - /path/to/appdata/config:/config
      - /path/to/backups:/backups
      - /path/to/source:/source
    ports:
      - PORTTOKEN
    restart: unless-stopped
EOF
    replaceInFile "PORTTOKEN" "$port:8200" docker-compose.yml
    progressBar $(steps 2 $steps) "Install Duplicati"

    docker-compose up -d
    askForNginxProxy "Duplicati" $port http
    progressBar $(steps 3 $steps) "Installed Duplicati"
}

############################################
##### UTILS
############################################

replaceInFile() {
  sed -i "s/$1/$2/g" $3
}

progressBar() {
  clear
  echo -n "[ "
  for ((i = 0; i <= $1; i++)); do echo -n "###"; done
  for ((j = i; j <= 10; j++)); do echo -n "   "; done
  v=$(($1 * 10))
  echo -n " ] "
  echo -n "$v % $2" $'\r'
  echo
}

steps() {
  percent=$(($1 * 100 / $2 / 10))
  echo $percent
}

askPort() {
  port=$(dialog --inputbox "$1" 0 0 "$2" 3>&1 1>&2 2>&3)
  {
    ufw allow "$port"
  } &>/dev/null
  echo -n "$port"
}

askForNginxProxy() {
  if [ "$nginxInstalled" -eq "1" ]; then
    dialog --yesno "Should a reverse proxy be setup for $1?" 0 0
    if [ $? = 0 ]; then
      generateProxyBasedOnUserInput $1 $2 $3
    fi
  fi
}

generateProxyBasedOnUserInput() {
  subdomain=$(dialog --inputbox "The subdomain under which $1 should be reachable (ex. docker for docker.nicojeske.de)" 0 0 "" 3>&1 1>&2 2>&3)
  domain=$(dialog --inputbox "Your main domain (ex: nicojeske.de)" 0 0 "" 3>&1 1>&2 2>&3)
  if [ -z "$2" ]; then
    port=$(askPort "Which port does the service use?")
  else
    port=$2
  fi

  if [ -z "$3" ]; then
    http=$(dialog --menu "Is the service reachable with http or https?" 0 0 0 "http" "" "https" "" 3>&1 1>&2 2>&3)
  else
    http=$3
  fi

  if [ $port = 10000 ] && [ $(dpkg-query -W -f='${Status}' nano 2>/dev/null | grep -c "ok installed") = 1 ]; then
    echo "referer=$subdomain.$domain" >> /etc/webmin/config
  fi

  addNginxProxy "$subdomain" "$domain" "$port" "$http"
}

addNginxProxy() {
  http_referer='$http_referer'
  remote_addr='$remote_addr'
  scheme='$scheme'
  server='$server_name'

  sudo tee -a /etc/nginx/sites-enabled/$2 >/dev/null <<EOT


server {
 listen 443 ssl;
 server_name $1.$2;
    ssl_certificate /etc/letsencrypt/live/$2/fullchain.pem; # managed by Certbot
    ssl_certificate_key /etc/letsencrypt/live/$2/privkey.pem; # managed by Certbot
  include /etc/letsencrypt/options-ssl-nginx.conf;
  ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;
  location / {
    proxy_pass $4://127.0.0.1:$3;
    proxy_set_header Referer $http_referer;
    proxy_set_header X-Forwarded-For $remote_addr;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header X-Forwarded-Host $server_name;
  }
}
EOT
  nginx -t
  /etc/init.d/nginx reload
}

#
#dialog --msgbox "Everything selected has been installed" 0 0
mainMenu "$@"
