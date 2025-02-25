#!/bin/bash

# Warna untuk output
GREEN='\e[32m'
RED='\e[31m'
YELLOW='\e[33m'
NC='\e[0m' # No Color

# Fungsi untuk mengatur nilai konfigurasi di php.ini
update_php_config() {
    local version=$1
    local setting=$2
    local value=$3
    local ini_file="/etc/php/$version/fpm/php.ini"
    
    if grep -q "^$setting" "$ini_file"; then
        sudo sed -i "s/^$setting.*/$setting = $value/" "$ini_file"
        echo -e "${GREEN}Updated $setting to $value in PHP $version${NC}"
    else
        echo -e "${YELLOW}$setting not found in PHP $version, adding it...${NC}"
        echo "$setting = $value" | sudo tee -a "$ini_file"
    fi
}

# Fungsi untuk mengatur memory_limit PHP
set_memory_limit() {
    read -p "Masukkan nilai memory_limit untuk PHP (contoh: 512M): " mem_limit
    for version in $(ls /etc/php/); do
        update_php_config "$version" "memory_limit" "$mem_limit"
    done
    sudo systemctl restart php*-fpm
}

# Fungsi untuk mengaktifkan atau menonaktifkan ekstensi PHP
manage_php_extension() {
    read -p "Masukkan versi PHP (misal: 8.2): " php_version
    read -p "Masukkan ekstensi yang ingin diaktifkan/nonaktifkan (contoh: intl): " extension
    read -p "Aktifkan (y) atau Nonaktifkan (n)? " choice
    if [ "$choice" == "y" ]; then
        sudo phpenmod -v "$php_version" "$extension"
        echo -e "${GREEN}Ekstensi $extension telah diaktifkan pada PHP $php_version${NC}"
    else
        sudo phpdismod -v "$php_version" "$extension"
        echo -e "${RED}Ekstensi $extension telah dinonaktifkan pada PHP $php_version${NC}"
    fi
    sudo systemctl restart php$php_version-fpm
}

# Fungsi untuk mengubah versi default Node.js
set_node_version() {
    read -p "Masukkan versi Node.js yang ingin digunakan (contoh: 18): " node_version
    sudo n $node_version
    echo -e "${GREEN}Node.js telah diperbarui ke versi $node_version${NC}"
}

# Fungsi untuk memperbaiki permission direktori web
fix_web_permissions() {
    read -p "Masukkan path direktori web yang ingin diperbaiki: " web_dir
    sudo chown -R www-data:www-data "$web_dir"
    sudo find "$web_dir" -type d -exec chmod 755 {} \;
    sudo find "$web_dir" -type f -exec chmod 644 {} \;
    echo -e "${GREEN}Permission direktori web telah diperbaiki.${NC}"
}

# Menu utama
while true; do
    echo -e "\n${GREEN}TuneServer - Optimasi Web Server & Database${NC}"
    echo "1) Set Memory Limit PHP"
    echo "2) Kelola Ekstensi PHP"
    echo "3) Ubah Versi Default Node.js"
    echo "4) Perbaiki Permission Direktori Web"
    echo "5) Keluar"
    read -p "Pilih opsi: " option
    case $option in
        1) set_memory_limit ;;
        2) manage_php_extension ;;
        3) set_node_version ;;
        4) fix_web_permissions ;;
        5) exit 0 ;;
        *) echo -e "${RED}Pilihan tidak valid.${NC}" ;;
    esac
done
