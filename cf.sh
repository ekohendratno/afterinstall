#!/bin/bash
set -e

##############################################
# CLOUDFLARE TUNNEL TOKEN
# 
# curl -fsSL https://s.id/mycloudflared -o install.sh
# chmod +x install.sh
# sudo bash install.sh
#
#
##############################################
CF_TOKEN="eyJhIjoiN2UzZjFjODZlZjZkN2ZiN2M2ODhlMTYwZDQ0NmQyOTQiLCJ0IjoiY2I4ZDRhMDQtM2E3Ni00MTA1LTgwNDYtNWY0OTBkMzQ1ODdjIiwicyI6Ik16bGlOemN3T0RZdE4yVmlaUzAwTlRneUxXRXhNMlV0WkdVM1pqUTBNalptTURZMiJ9"

clear
echo "============================================"
echo "      INSTALL CLOUDFLARED"
echo "============================================"

apt update
apt install -y curl gnupg ca-certificates

mkdir -p --mode=0755 /usr/share/keyrings

curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg \
| tee /usr/share/keyrings/cloudflare-main.gpg >/dev/null

cat >/etc/apt/sources.list.d/cloudflared.list <<EOF
deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared any main
EOF

apt update
apt install -y cloudflared

echo
echo "Cloudflared Version:"
cloudflared version

echo
echo "Menghapus service lama (jika ada)..."
systemctl stop cloudflared 2>/dev/null || true
cloudflared service uninstall 2>/dev/null || true

echo
echo "Install Cloudflare Tunnel..."
cloudflared service install "$CF_TOKEN"

systemctl daemon-reload
systemctl enable cloudflared
systemctl restart cloudflared

echo
echo "============================================"
echo "STATUS"
echo "============================================"
systemctl --no-pager status cloudflared || true

echo
echo "Selesai."
echo
echo "Log:"
echo "journalctl -u cloudflared -f"
