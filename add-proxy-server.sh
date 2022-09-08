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

echo "#!/bin/sh
pm2 start npm --name \"$domain\" -- run start:prod
pm2 save" > ~/sites/$domain/start.sh;

echo "#!/bin/sh
pm2 delete $domain;" > ~/sites/$domain/stop.sh;

echo "#!/bin/sh
./stop.sh;
./start.sh;" > ~/sites/$domain/restart.sh;

chmod 777 ~/sites/$domain/*.sh;