cat > /root/install-nextcloud-cloudflare.sh <<'EOF'
#!/bin/bash
set -e

echo "=================================================="
echo " INSTALL NEXTCLOUD + CLOUDFLARE TUNNEL"
echo " UBUNTU 24.04"
echo "=================================================="

DATA_DIR="/mnt/nextcloud-data"
WEB_DIR="/var/www/nextcloud"

DB_NAME="nextcloud"
DB_USER="nextclouduser"
DB_PASS=$(openssl rand -hex 16)

ADMIN_USER="admin"
ADMIN_PASS=$(openssl rand -hex 12)

IP_ADDR=$(hostname -I | awk '{print $1}')

# ==================================================
# CLOUDFLARE TUNNEL TOKEN
# ==================================================
TUNNEL_TOKEN="eyJhIjoiYWFiMDFmNjEyNDQ4MjJhODYyOTZhMDRlYmU0ODEyM2QiLCJ0IjoiMTMwYzUyZjAtZjQyYy00OTA2LWExNjAtZjI4ODc2OWFjYTVmIiwicyI6Ik9XTTRNV013WldNdE9EWTRNUzAwWmpZeExUaGtNV0l0TW1FeE16TmtNV0V4TVRZdyJ9"

echo ""
echo "[1] Cek mount data Nextcloud..."
if ! mountpoint -q "$DATA_DIR"; then
    echo "ERROR: $DATA_DIR belum termount."
    echo "Cek dengan: lsblk"
    exit 1
fi

echo ""
echo "[2] Update sistem awal..."
apt update
apt install -y curl wget sudo gnupg lsb-release ca-certificates apt-transport-https

echo ""
echo "[3] Install Cloudflare Tunnel / cloudflared..."

mkdir -p --mode=0755 /usr/share/keyrings

curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg \
  | tee /usr/share/keyrings/cloudflare-main.gpg >/dev/null

echo 'deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared any main' \
  | tee /etc/apt/sources.list.d/cloudflared.list >/dev/null

apt update
apt install -y cloudflared

echo ""
echo "[4] Install Cloudflare Tunnel Service..."

if [ -z "$TUNNEL_TOKEN" ] || [ "$TUNNEL_TOKEN" = "ISI_TOKEN_CLOUDFLARE_KAMU" ]; then
    echo "ERROR: TUNNEL_TOKEN belum diisi."
    echo "Edit script ini dulu:"
    echo "nano /root/install-nextcloud-cloudflare.sh"
    exit 1
fi

cloudflared service install "$TUNNEL_TOKEN" || true

systemctl enable cloudflared
systemctl restart cloudflared

echo ""
echo "[5] Status Cloudflare Tunnel..."
systemctl --no-pager status cloudflared || true

echo ""
echo "[6] Install Apache, MariaDB, PHP, Redis..."
apt install -y apache2 mariadb-server redis-server unzip bzip2 cron acl imagemagick \
php php-cli php-common php-mysql php-gd php-curl php-mbstring php-intl php-gmp php-bcmath \
php-xml php-zip php-imagick php-apcu php-redis php-bz2 libapache2-mod-php

systemctl enable --now apache2 mariadb redis-server

echo ""
echo "[7] Konfigurasi PHP..."
PHPVER=$(php -r 'echo PHP_MAJOR_VERSION.".".PHP_MINOR_VERSION;')

cat > /etc/php/$PHPVER/mods-available/nextcloud.ini <<PHPINI
memory_limit=1024M
upload_max_filesize=10G
post_max_size=10G
max_input_time=3600
max_execution_time=3600
date.timezone=Asia/Jakarta

opcache.enable=1
opcache.enable_cli=1
opcache.memory_consumption=256
opcache.interned_strings_buffer=32
opcache.max_accelerated_files=10000
opcache.save_comments=1
opcache.revalidate_freq=60
PHPINI

phpenmod nextcloud

echo ""
echo "[8] Buat database Nextcloud..."
mysql <<MYSQL_SCRIPT
CREATE DATABASE IF NOT EXISTS ${DB_NAME} CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
CREATE USER IF NOT EXISTS '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASS}';
GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'localhost';
FLUSH PRIVILEGES;
MYSQL_SCRIPT

echo ""
echo "[9] Download Nextcloud..."
cd /tmp
rm -rf nextcloud latest.tar.bz2

wget -O latest.tar.bz2 https://download.nextcloud.com/server/releases/latest.tar.bz2
tar -xjf latest.tar.bz2

rm -rf "$WEB_DIR"
mv nextcloud "$WEB_DIR"

echo ""
echo "[10] Set permission..."
mkdir -p "$DATA_DIR"

chown -R www-data:www-data "$WEB_DIR"
chown -R www-data:www-data "$DATA_DIR"

chmod 750 "$DATA_DIR"

echo ""
echo "[11] Konfigurasi Apache Nextcloud..."
cat > /etc/apache2/sites-available/nextcloud.conf <<APACHECONF
<VirtualHost *:80>
    ServerName ${IP_ADDR}
    DocumentRoot ${WEB_DIR}

    <Directory ${WEB_DIR}>
        Require all granted
        AllowOverride All
        Options FollowSymLinks MultiViews

        <IfModule mod_dav.c>
            Dav off
        </IfModule>
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/nextcloud_error.log
    CustomLog \${APACHE_LOG_DIR}/nextcloud_access.log combined
</VirtualHost>
APACHECONF

a2enmod rewrite headers env dir mime setenvif ssl
a2dissite 000-default.conf || true
a2ensite nextcloud.conf

systemctl restart apache2

echo ""
echo "[12] Install Nextcloud via OCC..."
sudo -u www-data php "$WEB_DIR/occ" maintenance:install \
  --database "mysql" \
  --database-name "$DB_NAME" \
  --database-user "$DB_USER" \
  --database-pass "$DB_PASS" \
  --admin-user "$ADMIN_USER" \
  --admin-pass "$ADMIN_PASS" \
  --data-dir "$DATA_DIR"

echo ""
echo "[13] Konfigurasi Nextcloud..."
sudo -u www-data php "$WEB_DIR/occ" config:system:set trusted_domains 0 --value="$IP_ADDR"
sudo -u www-data php "$WEB_DIR/occ" config:system:set trusted_domains 1 --value="localhost"

sudo -u www-data php "$WEB_DIR/occ" config:system:set overwrite.cli.url --value="http://$IP_ADDR"

sudo -u www-data php "$WEB_DIR/occ" config:system:set memcache.local --value='\OC\Memcache\APCu'
sudo -u www-data php "$WEB_DIR/occ" config:system:set memcache.distributed --value='\OC\Memcache\Redis'
sudo -u www-data php "$WEB_DIR/occ" config:system:set memcache.locking --value='\OC\Memcache\Redis'

sudo -u www-data php "$WEB_DIR/occ" config:system:set redis host --value='localhost'
sudo -u www-data php "$WEB_DIR/occ" config:system:set redis port --value='6379' --type=integer

sudo -u www-data php "$WEB_DIR/occ" background:cron

cat > /etc/cron.d/nextcloud <<CRON
*/5 * * * * www-data php -f ${WEB_DIR}/cron.php
CRON

systemctl restart apache2

cat > /root/nextcloud-info.txt <<INFO
==================================================
NEXTCLOUD INSTALL INFO
==================================================

URL Lokal  : http://${IP_ADDR}

Admin User : ${ADMIN_USER}
Admin Pass : ${ADMIN_PASS}

Database   : ${DB_NAME}
DB User    : ${DB_USER}
DB Pass    : ${DB_PASS}

Data Dir   : ${DATA_DIR}
Web Dir    : ${WEB_DIR}

Cloudflare:
Service    : cloudflared
Cek status : systemctl status cloudflared

==================================================
INFO

echo ""
echo "=================================================="
echo " NEXTCLOUD + CLOUDFLARE TUNNEL SELESAI"
echo "=================================================="
cat /root/nextcloud-info.txt
EOF

chmod +x /root/install-nextcloud-cloudflare.sh
nano /root/install-nextcloud-cloudflare.sh
