#!/bin/bash

echo "=============================================="
echo "   MENGHAPUS CLOUDFLARED + CLOUDFLARE TUNNEL  "
echo "=============================================="

# 1. Stop service jika ada
echo "[1] Menghentikan service cloudflared..."
sudo systemctl stop cloudflared 2>/dev/null

# 2. Disable service
echo "[2] Disable service cloudflared..."
sudo systemctl disable cloudflared 2>/dev/null

# 3. Hapus file service systemd
echo "[3] Menghapus file service di /etc/systemd/system..."
sudo rm -f /etc/systemd/system/cloudflared.service
sudo rm -f /etc/systemd/system/cloudflared*.service
sudo rm -f /etc/systemd/system/cloudflared*

# 4. Reload daemon
echo "[4] Reload systemd..."
sudo systemctl daemon-reload
sudo systemctl reset-failed

# 5. Hapus folder konfigurasi
echo "[5] Menghapus folder konfigurasi cloudflared..."
sudo rm -rf /etc/cloudflared
sudo rm -rf /root/.cloudflared
sudo rm -rf ~/.cloudflared

# 6. Hapus package cloudflared
echo "[6] Menghapus package cloudflared..."
sudo dpkg -r cloudflared 2>/dev/null
sudo dpkg -P cloudflared 2>/dev/null

# 7. Hapus binary jika masih ada
echo "[7] Menghapus binary cloudflared..."
sudo rm -f /usr/local/bin/cloudflared
sudo rm -f /usr/bin/cloudflared
sudo rm -f /usr/sbin/cloudflared

# 8. Hapus file installer bila ada
echo "[8] Menghapus file cloudflared.deb jika ada..."
rm -f cloudflared.deb 2>/dev/null

echo "=============================================="
echo "      SELURUH FILE CLOUDFlARED DIHAPUS         "
echo "=============================================="

# 9. Cek status
echo ""
echo "Cek status service (harus: NOT FOUND):"
systemctl status cloudflared 2>/dev/null || echo "cloudflared service sudah tidak ada."

echo ""
echo "Selesai!"
