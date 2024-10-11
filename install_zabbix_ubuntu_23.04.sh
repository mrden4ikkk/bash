#!/bin/bash

# Переменные
DB_PASSWORD='StrongPassword'   # Пароль для базы данных
ZABBIX_VERSION='7.0'           # Версия Zabbix

# Обновление системы
sudo apt update
sudo apt upgrade -y

# Установка MariaDB
sudo apt install mariadb-server -y

# Настройка MariaDB, проверка существования базы и пользователя
DB_EXISTS=$(sudo mysql -e "SHOW DATABASES LIKE 'zabbix';" | grep "zabbix")
USER_EXISTS=$(sudo mysql -e "SELECT user FROM mysql.user WHERE user = 'zabbix';" | grep "zabbix")

if [ -z "$DB_EXISTS" ]; then
    sudo mysql -e "CREATE DATABASE zabbix CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;"
else
    echo "База данных 'zabbix' уже существует, пропускаем создание."
fi

if [ -z "$USER_EXISTS" ]; then
    sudo mysql -e "CREATE USER 'zabbix'@'localhost' IDENTIFIED BY '${DB_PASSWORD}';"
    sudo mysql -e "GRANT ALL PRIVILEGES ON zabbix.* TO 'zabbix'@'localhost';"
    sudo mysql -e "FLUSH PRIVILEGES;"
else
    echo "Пользователь 'zabbix' уже существует, пропускаем создание."
fi

# Установка репозитория Zabbix
wget https://repo.zabbix.com/zabbix/${ZABBIX_VERSION}/ubuntu/pool/main/z/zabbix-release/zabbix-release_${ZABBIX_VERSION}-1+ubuntu23.04_all.deb
if [ -f zabbix-release_${ZABBIX_VERSION}-1+ubuntu23.04_all.deb ]; then
    sudo dpkg -i zabbix-release_${ZABBIX_VERSION}-1+ubuntu23.04_all.deb
else
    echo "Ошибка: файл репозитория Zabbix не найден. Проверьте версию Zabbix и доступность пакета."
    exit 1
fi
sudo apt update

# Установка Zabbix Server, Web и Agent
sudo apt install zabbix-server-mysql zabbix-frontend-php zabbix-nginx-conf zabbix-agent -y

# Импорт схемы базы данных
if [ -f /usr/share/doc/zabbix-server-mysql*/create.sql.gz ]; then
    sudo zcat /usr/share/doc/zabbix-server-mysql*/create.sql.gz | mysql -uzabbix -p${DB_PASSWORD} zabbix
else
    echo "Ошибка: схема базы данных Zabbix не найдена."
    exit 1
fi

# Настройка Zabbix Server
sudo sed -i "s/# DBPassword=/DBPassword=${DB_PASSWORD}/" /etc/zabbix/zabbix_server.conf

# Настройка PHP для Zabbix
sudo sed -i "s/# php_value date.timezone.*/php_value date.timezone Europe\/Moscow/" /etc/zabbix/nginx.conf

# Перезапуск сервисов
sudo systemctl restart zabbix-server zabbix-agent nginx
sudo systemctl enable zabbix-server zabbix-agent nginx

# Завершение
echo "Zabbix установлен. Перейдите на http://<server-ip>/zabbix для завершения установки через веб-интерфейс."

