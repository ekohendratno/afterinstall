#!/bin/bash

# Warna untuk output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Fungsi untuk membuat website baru
create_website() {
    echo -e "${YELLOW}Masukkan nama web:${NC}"
    read WEB_NAME
    DB_NAME=$(echo "$WEB_NAME" | tr '-' '_')

    echo -e "${YELLOW}Masukkan port:${NC}"
    read PORT

    echo -e "${YELLOW}Pilih tipe web (php/nodejs):${NC}"
    read WEB_TYPE

    if [[ "$WEB_TYPE" == "php" ]]; then
        echo -e "${YELLOW}Pilih versi PHP (7.1 - 8.3):${NC}"
        read PHP_VERSION
    elif [[ "$WEB_TYPE" == "nodejs" ]]; then
        echo -e "${YELLOW}Pilih versi Node.js (16 - 20):${NC}"
        read NODE_VERSION
    else
        echo -e "${RED}Tipe web tidak valid!${NC}"
        exit 1
    fi

    echo -e "${GREEN}Membuat database...${NC}"
    mysql -u srv -psrV@1234 -e "CREATE DATABASE $DB_NAME;"

    WEB_DIR="/var/www/$WEB_NAME"
    echo -e "${GREEN}Membuat direktori web di $WEB_DIR...${NC}"
    mkdir -p "$WEB_DIR"

    if [[ "$WEB_TYPE" == "php" ]]; then
        echo -e "${GREEN}Mengatur PHP versi $PHP_VERSION...${NC}"
        echo "<?php phpinfo(); ?>" > "$WEB_DIR/index.php"
        CONFIG_FILE="/etc/nginx/sites-available/$WEB_NAME"
        echo "server {
            listen $PORT;
            server_name $WEB_NAME;
            root $WEB_DIR;
            index index.php;

            location / {
                try_files \$uri \$uri/ =404;
            }

            location ~ \.php$ {
                include snippets/fastcgi-php.conf;
                fastcgi_pass unix:/run/php/php$PHP_VERSION-fpm.sock;
                fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
                include fastcgi_params;
            }
        }" > "$CONFIG_FILE"
    elif [[ "$WEB_TYPE" == "nodejs" ]]; then
        echo -e "${GREEN}Mengatur Node.js versi $NODE_VERSION...${NC}"
        echo "console.log('Selamat datang di $WEB_NAME');" > "$WEB_DIR/index.js"
        CONFIG_FILE="/etc/nginx/sites-available/$WEB_NAME"
        echo "server {
            listen $PORT;
            server_name $WEB_NAME;

            location / {
                proxy_pass http://localhost:$PORT/;
                proxy_http_version 1.1;
                proxy_set_header Upgrade \$http_upgrade;
                proxy_set_header Connection 'upgrade';
                proxy_set_header Host \$host;
                proxy_cache_bypass \$http_upgrade;
            }
        }" > "$CONFIG_FILE"
    fi

    ln -s "$CONFIG_FILE" "/etc/nginx/sites-enabled/"
    systemctl restart nginx
    echo -e "${GREEN}Website $WEB_NAME berhasil dibuat di port $PORT!${NC}"
}

create_website
