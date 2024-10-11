#!/bin/bash

sudo apt update && sudo apt upgrade -y

sudo apt install -y apache2 mysql-server php libapache2-mod-php php-mysql wget unzip

DB_NAME="wordpress"
DB_USER="wordpressuser"
DB_PASSWORD="wordpress"

sudo mysql -e "CREATE DATABASE ${DB_NAME};"
sudo mysql -e "CREATE USER '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASSWORD}';"
sudo mysql -e "GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'localhost';"
sudo mysql -e "FLUSH PRIVILEGES;"

wget -c https://wordpress.org/latest.zip
unzip latest.zip
sudo mv wordpress /var/www/html/wordpress

sudo chown -R www-data:www-data /var/www/html/wordpress
sudo chmod -R 755 /var/www/html/wordpress

sudo bash -c 'cat > /etc/apache2/sites-available/wordpress.conf <<EOF
<VirtualHost *:80>
    ServerAdmin admin@localhost
    DocumentRoot /var/www/html/wordpress
    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF'

sudo a2ensite wordpress.conf
sudo systemctl restart apache2

cd /var/www/html/wordpress
cp wp-config-sample.php wp-config.php

sudo sed -i "s/database_name_here/${DB_NAME}/" wp-config.php
sudo sed -i "s/username_here/${DB_USER}/" wp-config.php
sudo sed -i "s/password_here/${DB_PASSWORD}/" wp-config.php

