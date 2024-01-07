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