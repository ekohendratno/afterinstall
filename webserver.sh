#!/bin/bash

# ===========================
# Web Server Setup for Ubuntu 22.04
# ===========================

# Warna untuk output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Pastikan script dijalankan sebagai root
if [[ $EUID -ne 0 ]]; then
    echo -e "${RED}Jalankan script ini sebagai root!${NC}"
    exit 1
fi

# Fungsi untuk memeriksa dan menginstal paket
install_package() {
    if dpkg -s "$1" &> /dev/null; then
        echo -e "${YELLOW}$1 sudah terinstall.${NC}"
    else
        echo -e "${GREEN}Menginstall $1...${NC}"
        apt install -y "$1"
    fi
}

# Update sistem
echo -e "${GREEN}Memperbarui sistem...${NC}"
apt update && apt upgrade -y

# Install Nginx
install_package nginx
systemctl enable --now nginx

# Install MySQL
install_package mysql-server
systemctl enable --now mysql

# Buat akun database
echo -e "${GREEN}Membuat user dan database MySQL...${NC}"
mysql -u root -e "CREATE USER IF NOT EXISTS 'srv'@'localhost' IDENTIFIED BY 'srV@1234';"
mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO 'srv'@'localhost' WITH GRANT OPTION;"
mysql -u root -e "FLUSH PRIVILEGES;"

# Install PHP 7.1 - 8.3
add-apt-repository -y ppa:ondrej/php
apt update
PHP_VERSIONS=(7.1 7.2 7.3 7.4 8.0 8.1 8.2 8.3)
for version in "${PHP_VERSIONS[@]}"; do
    install_package "php$version"
    install_package "php$version-fpm"
    install_package "php$version-mysql"
    install_package "php$version-curl"
    install_package "php$version-mbstring"
    install_package "php$version-xml"
    install_package "php$version-zip"
done

# Set PHP default ke 8.2
update-alternatives --set php /usr/bin/php8.2

# Install Node.js 16 - 20
install_package curl
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
install_package nodejs
npm install -g n
for version in {16..20}; do
    n $version
    echo -e "${GREEN}Node.js versi $version terinstall.${NC}"
done

# Install phpMyAdmin di port 8888
install_package phpmyadmin
cat > /etc/nginx/sites-available/phpmyadmin <<EOF
server {
    listen 8888;
    server_name _;
    root /usr/share/phpmyadmin;
    index index.php index.html;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php$ {
        include fastcgi_params;
        fastcgi_pass unix:/run/php/php8.2-fpm.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
    }
}
EOF
ln -s /etc/nginx/sites-available/phpmyadmin /etc/nginx/sites-enabled/
systemctl restart nginx

echo -e "${GREEN}Instalasi selesai!${NC}"
