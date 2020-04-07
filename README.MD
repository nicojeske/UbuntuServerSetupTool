# Ubuntu Server Setup Tool

The Ubuntu Server Setup Tool (USST) is a Bash-script you can use to automatically install software and docker containers with a simple GUI.
 It also acts as a tool to easily create reverse proxys  with Nginx.

[![License](http://img.shields.io/:license-mit-blue.svg?style=flat-square)](http://badges.mit-license.org)


![](https://nicojeske.de/usst/install.gif)

## Table of Contents


- [Overview](#overview)
- [Getting Started](#getting-started)
- [Contributing](#contributing)
- [Options](#options)
    - [Installs](#installs)
        - [Webmin](#webmin)
        - [ZSH](#webmin)
        - [Nginx](#webmin)
        - [Docker](#webmin)
    - [Container](#container)
    - [Add nginx reverse proxy](#addnginxproxy)
- [Contributing](#contributing)
- [Contributors](#contributors)
- [License](#license)

---
## Overview
This is a tool fitting my personal setup procedure on a new ubuntu machine and therefore using 
the configuration I normally use to setup my servers. Therefore to really get the most out of this tool you should have following setup:
* Domain with DNS managed by Cloudflare

## Getting Started

### Clone

- Clone this repo to your local machine using `git clone https://github.com/nicojeske/SetupScripts`

### Usage
- Make the installer script executable using `chmod +x /SetupScripts/linuxInstallTool.sh`
- Run the installer script with root privileges using `sudo /SetupScripts/linuxInstallTool.sh`
- Select what you want in the setup tool. Be sure to check out the description in [Options](#options) too see exactly what the option would do.

---
# Options
## Installs
![](https://nicojeske.de/usst/install.gif)
### Webmin
This will install [webmin](http://www.webmin.com/) and [usermin](http://www.webmin.com/usermin.html) with webmin listening on port 10000 and usermin on port 20000

***Important:*** If you want to access webmin via a subdomain like webmin.example.com you should use the option AddNginxProxy to generate a reverse Proxy for webmin (Running on port 10000) as this will setup the domain in webmin. Otherwise you would not be able to connect to webmin from outside.
### ZSH
This will install [ZSH](https://www.zsh.org/) and [ohmyzsh](https://ohmyz.sh/) applying some custom styling and installing the [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting) plugin
for syntax highlighting in the shell. During the install you are asked by Oh My Zsh if you want to set zsh as your default shell. Answer with yes then use `exit` to continue the install script.

### Nginx with SSL
This will install [Nginx](http://nginx.com/) together with a wildcard SSL Certificate from [LetsEncrypt](https://letsencrypt.org/).
To use this option you need a domain with the SSL settings managed with [Cloudflare](https://www.cloudflare.com/).

During the install you get asked for your Cloudflare Email adress and your Clouflare API token which is needed to automatically generate a wildcard SSL certificate for you.

You can find your Cloudflare API Token this way:
* Open your domain on Cloudflare
* In the right sidebar scroll to the section API and open "Get your API token"
* In the category API Keys select view for "Global API Key"
* Enter your password and you will find your API Key.

### Docker
This will install [Docker](https://www.docker.com/) and [Dockercompose](https://docs.docker.com/compose/).

---
## Container
![](https://nicojeske.de/usst/container.gif)
To use this menu option docker must be installed. It is advised to have Nginx also installed to directly add reverse proxys for your Containers.

You can currently install following containers:
* [Portainer](https://hub.docker.com/r/portainer/portainer) - a docker webinterface
* [Statping](https://hub.docker.com/r/statping/statping) - a status page for your services
* [Teamspeak](https://hub.docker.com/_/teamspeak) - VOIP software
* [Sinusbot](https://hub.docker.com/r/sinusbot/docker) - Musicbot for Teamspeak
* [Nextcloud](https://hub.docker.com/_/nextcloud) - Selfhosted cloud storage
* [Heimdall](https://hub.docker.com/r/linuxserver/heimdall) - Startpage
* [Duplicati](https://hub.docker.com/r/linuxserver/duplicati) - Backup solution
* [Watchtower](https://hub.docker.com/r/containrrr/watchtower) - Automatic container updates

The following containers use docker-compose:
 * Statping
 * Nextcloud
 * Heimdall
 * Duplicati
 
 The docker-compose.yml file can be found in `/var/linuxsetuptool/\<ContainerName\>`.
 ### Reverse Proxying
 If nginx is installed the tool will automatically ask for a subdomain and a domain of your server. It then automatically adds an reverse proxy for the container in nginx.
 
## AddNginxProxy
![](https://nicojeske.de/usst/nginx.gif)
If you have some tool running on a specific port you can easily create a reverse proxy for it using this option.

## Contributing
Feel free to contribute to the tool and add more software and containers that can be automatically installed.
### Step 1
- 🍴 Fork this repo!
### Step 2

- **HACK AWAY!** 🔨🔨🔨

### Step 3

- 🔃 Create a new pull request.

---

## Contributors
| <a href="https://nicojeske.de" target="_blank">**Nico Jeske**</a> |
| :---: |
| [![Nico Jeske](https://avatars2.githubusercontent.com/u/17299108?s=460&u=a3e620760024eff78d39dc7e4f299631543ee986&v=4s=200)](https://nicojeske.de)
| <a href="http://github.com/nicojeske" target="_blank">`github.com/nicojeske`</a>

---

## License

[![License](http://img.shields.io/:license-mit-blue.svg?style=flat-square)](http://badges.mit-license.org)

- **[MIT license](http://opensource.org/licenses/mit-license.php)**
- Copyright 2020 © <a href="https://nicojeske.de" target="_blank">Nico Jeske</a>.
