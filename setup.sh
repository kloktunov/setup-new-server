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

su - $username << EOF
    git clone https://github.com/kloktunov/setup-new-server.git;
    chmod 777 ./setup-new-server/*.sh;
EOF

# ==================================
# SETUP NGINX
# ==================================
apt-get install nginx -y;

cp /home/$username/setup-new-server/nginx-configs/default /etc/nginx/sites-available/default;

sed -i "s/USERNAME/$username/" /etc/nginx/sites-available/default;
sed -i "s/# server_names_hash_bucket_size 64/server_names_hash_bucket_size 256/" /etc/nginx/nginx.conf;

service nginx restart;

# ==================================
# SETUP NODEJS
# ==================================
apt install ca-certificates;

rm /usr/share/ca-certificates/mozilla/DST_Root_CA_X3.crt;
update-ca-certificates;


curl -sL https://deb.nodesource.com/setup_14.x | sudo bash -;

apt-get update;

apt-get install nodejs -y;

npm install -g pm2;
pm2 startup;


echo "# ================================";
echo "# NODEJS CHECK";
echo "# ================================";
node -v;
echo "# --------------------------------";

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

# ==================================
# SETUP POSTGRESQL
# ==================================
su - $username << EOF
    
    echo $password | sudo -S echo "setup password";
    mkdir ~/download;
    mkdir ~/cert;
    wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -;
    RELEASE=$(lsb_release -cs);
    echo "deb http://apt.postgresql.org/pub/repos/apt/ ${RELEASE}"-pgdg main | sudo tee  /etc/apt/sources.list.d/pgdg.list;
    sudo apt update;
    sudo apt -y install postgresql-11;
    sudo ss -tunelp | grep 5432;

EOF

sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" /etc/postgresql/11/main/postgresql.conf;
echo 'host  all  all 0.0.0.0/0 md5' >>  /etc/postgresql/11/main/pg_hba.conf;

su - postgres << EOF

    # read -p "Введите пароль для базы данных: " dbpassword;
    psql -c "alter user postgres with password '$password'";
    
#    read -p "Введите название базы данных: " $dbname;
#    psql -c "CREATE DATABASE $dbname";
    
    echo "DB User: postgres";
    echo "DB Password: $password";
#    echo "DB Name: $dbname";

EOF

service postgresql restart;

su - $username;