#!/bin/bash

# Tune and optimize web server and database performance
# Ensure the user managing SSH can modify files in web directories

set -e

# Define web directory
WEB_DIR="/var/www"
MANAGEMENT_USER="sshuser"

# Ensure correct permissions for management user
echo "Setting permissions for $MANAGEMENT_USER on $WEB_DIR..."
sudo chown -R $MANAGEMENT_USER:$MANAGEMENT_USER $WEB_DIR
sudo chmod -R 775 $WEB_DIR
sudo setfacl -R -m u:$MANAGEMENT_USER:rwx $WEB_DIR

# Tune PHP settings
PHP_VERSION=$(php -r "echo PHP_MAJOR_VERSION.'.'.PHP_MINOR_VERSION;")
PHP_INI="/etc/php/$PHP_VERSION/fpm/php.ini"

echo "Tuning PHP settings..."
sudo sed -i "s/^memory_limit = .*/memory_limit = 512M/" $PHP_INI
sudo sed -i "s/^upload_max_filesize = .*/upload_max_filesize = 100M/" $PHP_INI
sudo sed -i "s/^post_max_size = .*/post_max_size = 100M/" $PHP_INI
sudo sed -i "s/^max_execution_time = .*/max_execution_time = 300/" $PHP_INI
sudo systemctl restart php$PHP_VERSION-fpm

# Tune MySQL settings
MYSQL_CONF="/etc/mysql/my.cnf"
echo "Tuning MySQL settings..."
sudo sed -i "s/^max_connections.*/max_connections = 500/" $MYSQL_CONF
sudo sed -i "s/^query_cache_size.*/query_cache_size = 64M/" $MYSQL_CONF
sudo systemctl restart mysql

# Tune phpMyAdmin settings
PMA_CONF="/etc/phpmyadmin/config.inc.php"
echo "Tuning phpMyAdmin settings..."
sudo sed -i "s/\$cfg\['ExecTimeLimit'\] = .*/\$cfg['ExecTimeLimit'] = 300;/" $PMA_CONF
sudo sed -i "s/\$cfg\['MaxRows'\] = .*/\$cfg['MaxRows'] = 5000;/" $PMA_CONF
sudo sed -i "s/\$cfg\['UploadDir'\] = .*/\$cfg['UploadDir'] = '\/var\/lib\/phpmyadmin\/upload';/" $PMA_CONF
sudo sed -i "s/\$cfg\['SaveDir'\] = .*/\$cfg['SaveDir'] = '\/var\/lib\/phpmyadmin\/save';/" $PMA_CONF
sudo systemctl restart apache2 || sudo systemctl restart nginx

echo "Server tuning completed successfully!"
