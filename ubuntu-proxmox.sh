#!/bin/bash

# Memperbarui sistem
echo "Memperbarui sistem..."
sudo apt update && sudo apt upgrade -y

# Menginstal qemu-guest-agent
echo "Menginstal qemu-guest-agent..."
sudo apt install qemu-guest-agent -y

# Menginstal cloud-init
echo "Menginstal cloud-init..."
sudo apt install cloud-init -y

# Menginstal editor teks nano
echo "Menginstal nano..."
sudo apt install nano -y

# Menghapus baris yang tidak diperlukan dari /etc/cloud/cloud.cfg
echo "Mengonfigurasi cloud-init..."
sudo sed -i '/snap/d' /etc/cloud/cloud.cfg
sudo sed -i '/ubuntu-advantage/d' /etc/cloud/cloud.cfg
sudo sed -i '/disable-ec2-metadata/d' /etc/cloud/cloud.cfg
sudo sed -i '/byobu/d' /etc/cloud/cloud.cfg
sudo sed -i '/fan/d' /etc/cloud/cloud.cfg
sudo sed -i '/landscape/d' /etc/cloud/cloud.cfg
sudo sed -i '/lxd/d' /etc/cloud/cloud.cfg
sudo sed -i '/puppet/d' /etc/cloud/cloud.cfg
sudo sed -i '/chef/d' /etc/cloud/cloud.cfg
sudo sed -i '/mcollective/d' /etc/cloud/cloud.cfg
sudo sed -i '/salt-minion/d' /etc/cloud/cloud.cfg
sudo sed -i '/rightscale_userdata/d' /etc/cloud/cloud.cfg

# Menghapus machine-id dan membuat file kosong
echo "Mengatur ulang machine-id..."
sudo rm -f /etc/machine-id
sudo touch /etc/machine-id

# Membersihkan sistem
echo "Membersihkan sistem..."
sudo apt clean -y
sudo apt autoclean -y
sudo apt autoremove --purge -y

# Mengoptimalkan ruang disk
echo "Mengoptimalkan ruang disk..."
sudo fstrim -av

echo "Proses pasca-instalasi selesai."
