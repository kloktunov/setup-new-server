#!/bin/sh

# ===============================
# SETUP NEW USER
# ===============================
read -p "Введите новое имя пользователя: " username;
adduser $username;
usermod -aG sudo $username;


# ===============================
# SETUP UTILS
# ===============================
apt-get update;
apt-get install -y mc;
apt-get install -y git;
apt-get install curl -y;
apt-get install gnupg
apt-get install ca-certificates
apt-get install lsb-release
apt-get install sudo -y;


echo "# ================================";
echo "# INSTALL DOCKER";
echo "# ================================";
# apt-get install docker.io docker-ce docker-ce-cli containerd.io docker-compose-plugin -y;
# Определение дистрибутива
. /etc/os-release
DISTRO=$ID

# Функция для установки Docker
install_docker() {
    # Установка необходимых пакетов
    apt-get update
    apt-get install -y apt-transport-https ca-certificates curl software-properties-common

    # Добавление GPG ключа Docker
    curl -fsSL https://download.docker.com/linux/$DISTRO/gpg | sudo apt-key add -

    # Добавление репозитория Docker
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/$DISTRO $(lsb_release -cs) stable"

    # Установка Docker
    apt-get update
    apt-get install -y docker-ce
}

# Функция для установки Docker Compose
install_docker_compose() {
    # Установка Docker Compose
    sudo curl -L "https://github.com/docker/compose/releases/download/v2.0.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
}

# Вызов функций
install_docker
install_docker_compose

# Add permsission to docker sock
chmod 666 /var/run/docker.sock
usermod -aG docker $username
systemctl restart docker.service

# Проверка установки
echo "# ================================";
echo "# DOCKER COMPOSE INFO";
echo "# ================================";
docker --version
docker-compose --version


# echo "# ================================";
# echo "# INSTALL DOCKER COMPOSE";
# echo "# ================================";
# curl -L https://github.com/docker/compose/releases/download/1.25.3/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose;
# sudo chmod +x /usr/local/bin/docker-compose;
# docker-compose --version;
# usermod -aG docker $username;

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