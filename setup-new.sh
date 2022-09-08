#!/bin/sh

# ===============================
# SETUP NEW USER
# ===============================
read -p "Введите новое имя пользователя: " username;
read -p "Введите пароль пользователя: " password;
adduser $username;
usermod -aG sudo $username;


# ===============================
# SETUP UTILS
# ===============================
apt-get update;
apt-get install -y mc;
apt-get install -y git;
apt-get install curl -y;
apt-get install sudo -y;
apt-get install ca-certificates -y;
apt-get install gnupg -y
apt-get install lsb-release -y;


su - $username << EOF
    git clone https://github.com/kloktunov/setup-new-server.git;
    # chmod 777 ./setup-new-server/*.sh;
EOF


# ==================================
# SETUP NGINX
# ==================================
apt-get install nginx -y;

cp /home/$username/setup-new-server/nginx-configs/default /etc/nginx/sites-available/default;

sed -i "s/USERNAME/$username/" /etc/nginx/sites-available/default;
sed -i "s/# server_names_hash_bucket_size 64;/server_names_hash_bucket_size 256;\n\tclient_max_body_size 100M;/" /etc/nginx/nginx.conf;

# ==================================
# SETUP CERTBOT
# ==================================
apt-get install certbot -y;

crontab -l > crontabcache;

echo '0 12 * * * /usr/bin/certbot renew --post-hook "service nginx restart"' >> crontabcache;

crontab crontabcache;

rm crontabcache;

echo "# ================================";
echo "# CRONTAB CHECK";
echo "# ================================";
crontab -l;
echo "# --------------------------------";

echo "# ================================";
echo "# INSTALL DOCKER";
echo "# ================================";
apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y;

echo "# ================================";
echo "# INSTALL DOCKER COMPOSE";
echo "# ================================";
curl -L https://github.com/docker/compose/releases/download/1.25.3/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose;
sudo chmod +x /usr/local/bin/docker-compose;
docker-compose --version;
usermod -aG docker $username;

echo "# ================================";
echo "# INSTALL GITHUB";
echo "# ================================";

curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg;
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null;
apt update;
apt install gh -y;

su - $username << EOF
    gh auth login;
EOF

su - $username