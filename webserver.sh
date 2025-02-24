#!/bin/bash

# Pastikan script dijalankan sebagai root
if [[ $EUID -ne 0 ]]; then
    echo "Jalankan script ini sebagai root!"
    exit 1
fi

# Update dan upgrade sistem
echo "Updating system..."
apt update && apt upgrade -y

# Install Nginx
echo "Installing Nginx..."
apt install -y nginx
systemctl enable --now nginx

# Install MySQL
echo "Installing MySQL..."
apt install -y mysql-server
systemctl enable --now mysql

# Buat user dan database MySQL
echo "Creating MySQL user and database..."
mysql -u root -e "CREATE USER 'srv'@'localhost' IDENTIFIED BY 'srV@1234';"
mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO 'srv'@'localhost' WITH GRANT OPTION;"
mysql -u root -e "FLUSH PRIVILEGES;"

# Install PHP (7.1 - 8.3)
echo "Adding PHP repository..."
add-apt-repository -y ppa:ondrej/php
apt update

PHP_VERSIONS=(7.1 7.2 7.3 7.4 8.0 8.1 8.2 8.3)
echo "Installing PHP versions..."
for version in "${PHP_VERSIONS[@]}"; do
    apt install -y php$version php$version-fpm php$version-mysql php$version-curl php$version-mbstring php$version-xml php$version-zip
done

# Set PHP default ke 8.2
echo "Setting default PHP to 8.2..."
update-alternatives --set php /usr/bin/php8.2

# Install Node.js (16 - 20)
echo "Installing Node.js..."
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt install -y nodejs
npm install -g n
n 20

echo "Installing Node.js versions 16 - 20..."
for version in {16..20}; do
    n $version
    npm install -g n
    n $version
done

# Install phpMyAdmin
echo "Installing phpMyAdmin..."
apt install -y phpmyadmin

# Konfigurasi phpMyAdmin di port 8888
echo "Configuring phpMyAdmin on port 8888..."
cat > /etc/nginx/sites-available/phpmyadmin <<EOF
server {
    listen 8888;
    server_name localhost;
    root /usr/share/phpmyadmin;
    index index.php;

    location / {
        try_files \$uri \$uri/ /index.php\$query_string;
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

echo "Web server installation complete!"
