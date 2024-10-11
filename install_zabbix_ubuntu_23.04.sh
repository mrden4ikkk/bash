#!/bin/bash

sudo apt update && sudo apt upgrade -y
sudo apt install -y wget curl gnupg2 lsb-release

sudo apt install -y mariadb-server
sudo mysql_secure_installation

DB_NAME="zabbix"
DB_USER="zabbix"
DB_PASSWORD="zabbix"

sudo mysql -e "CREATE DATABASE $DB_NAME CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
sudo mysql -e "CREATE USER '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASSWORD';"
sudo mysql -e "GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'localhost';"
sudo mysql -e "FLUSH PRIVILEGES;"

wget https://repo.zabbix.com/zabbix/7.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_7.0-1+ubuntu22.04_all.deb
sudo dpkg -i zabbix-release_7.0-1+ubuntu22.04_all.deb
sudo apt update

sudo apt install -y zabbix-server-mysql zabbix-frontend-php zabbix-agent

sudo zcat /usr/share/doc/zabbix-server-mysql*/create.sql.gz | sudo mysql -u $DB_USER -p$DB_PASSWORD $DB_NAME

sudo sed -i "s/# DBPassword=/DBPassword=$DB_PASSWORD/" /etc/zabbix/zabbix_server.conf

sudo bash -c 'cat >> /etc/php/*/fpm/php.ini << EOF
date.timezone = "Europe/Kyiv"
EOF'

sudo systemctl restart zabbix-server zabbix-agent apache2
sudo systemctl enable zabbix-server zabbix-agent apache2



