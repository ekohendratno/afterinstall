curl -sS https://installer.cloudpanel.io/ce/v2/install.sh -o install.sh; \
echo "a3ba69a8102345127b4ae0e28cfe89daca675cbc63cd39225133cdd2fa02ad36 install.sh" | \
sha256sum -c && sudo bash install.sh
