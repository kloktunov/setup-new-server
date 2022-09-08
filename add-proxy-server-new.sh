#!/bin/sh

username="$(whoami)";
read -p "Введите домен: " domain;
read -p "Введите порт: " port;

# =============================
# CREATE CONFIG FOR SERVER
# =============================

sudo cp ~/setup-new-server/nginx-configs/proxy-server /etc/nginx/sites-available/$domain;

sudo sed -i "s/DOMAIN/$domain/" /etc/nginx/sites-available/$domain;
sudo sed -i "s/PORT/$port/" /etc/nginx/sites-available/$domain;

sudo ln -sf /etc/nginx/sites-available/$domain /etc/nginx/sites-enabled/$domain;

# =============================
# CREATE SSL CERT FOR SERVER
# =============================
sudo certbot certonly --email support@$domain --webroot -w /home/$username/cert -d $domain

sudo su << EOF
    service nginx restart;
EOF

mkdir ~/sites;
mkdir ~/sites/$domain;
cd ~/sites/$domain;