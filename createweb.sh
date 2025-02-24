#!/bin/bash

# Pastikan skrip dijalankan sebagai root
if [ "$(id -u)" -ne 0 ]; then
    echo "Harap jalankan skrip ini sebagai root atau dengan sudo!"
    exit 1
fi

# Minta input dari pengguna
read -p "Masukkan nama web: " WEB_NAME
WEB_NAME_SANITIZED=${WEB_NAME//-/_}
read -p "Masukkan nama database: " DB_NAME
read -p "Masukkan port: " PORT
read -p "Pilih tipe web (php/nodejs): " WEB_TYPE

# Menentukan versi yang tersedia berdasarkan tipe
if [ "$WEB_TYPE" == "php" ]; then
    echo "Pilih versi PHP (7.1-8.3):"
    read -p "Versi PHP: " PHP_VERSION
elif [ "$WEB_TYPE" == "nodejs" ]; then
    echo "Pilih versi Node.js (16-20):"
    read -p "Versi Node.js: " NODE_VERSION
else
    echo "Tipe web tidak valid!"
    exit 1
fi

# Membuat direktori website
WEB_DIR="/var/www/$WEB_NAME"
mkdir -p $WEB_DIR

# Konfigurasi Nginx
NGINX_CONF="/etc/nginx/sites-available/$WEB_NAME"
echo "server {
    listen $PORT;
    server_name localhost;
    root $WEB_DIR;
    index index.html index.php index.js;

    location / {
        try_files \$uri \$uri/ =404;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php$PHP_VERSION-fpm.sock;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
    }
}" > $NGINX_CONF

ln -s $NGINX_CONF /etc/nginx/sites-enabled/

# Konfigurasi file contoh
if [ "$WEB_TYPE" == "php" ]; then
    echo "<?php phpinfo(); ?>" > "$WEB_DIR/index.php"
    chown -R www-data:www-data "$WEB_DIR"
    chmod -R 755 "$WEB_DIR"

elif [ "$WEB_TYPE" == "nodejs" ]; then
    echo "const http = require('http');
const server = http.createServer((req, res) => {
    res.writeHead(200, {'Content-Type': 'text/plain'});
    res.end('Selamat datang di $WEB_NAME!');
});
server.listen($PORT, () => {
    console.log('Server berjalan di port $PORT');
});" > "$WEB_DIR/index.js"

    cd "$WEB_DIR"
    nvm use $NODE_VERSION
    npm init -y
    npm install

    chown -R www-data:www-data "$WEB_DIR"
    chmod -R 755 "$WEB_DIR"

    # Menjalankan server Node.js
    nohup node "$WEB_DIR/index.js" > "$WEB_DIR/output.log" 2>&1 &
fi

# Membuat database
mysql -usrv -psrV@1234 -e "CREATE DATABASE $DB_NAME;"

# Restart layanan
systemctl restart nginx

echo "Website $WEB_NAME berhasil dibuat dan berjalan di port $PORT!"
