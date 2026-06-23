#!/bin/bash
set -e

##############################################
# CLOUDFLARE TUNNEL TOKEN
##############################################
CF_TOKEN="eyJhIjoiYWFiMDFmNjEyNDQ4MjJhODYyOTZhMDRlYmU0ODEyM2QiLCJ0IjoiZTg4MzExMTQtMGJlMC00YzQxLTk5ZTctZjkzYzhlZWNkY2MxIiwicyI6Ik4yUmlNalF5TkdZdFlqRXpOQzAwWkRnM0xXSm1OR1l0TldabU0yRTJNREExWlRGaCJ9"

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
