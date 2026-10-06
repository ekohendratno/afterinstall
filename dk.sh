#!/usr/bin/env bash

set -uo pipefail

# =====================================================
# CLOUDPANEL CBT CI4 DEPLOYER - SMART VERSION
# =====================================================
#


# =====================================================
# WARNA
# =====================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BLUE='\033[0;34m'
NC='\033[0m'


# =====================================================
# KONFIGURASI SOURCE / MASTER
# =====================================================

# Master1: karakter.dsmartlampung.com
MASTER1_NAME="karakter"
MASTER1_DOMAIN="karakter.dsmartlampung.com"
MASTER1_USER="dsmartlampung-karakter"
MASTER1_DB="dsmartlampung-karakter"
MASTER1_DB_USER="dsmartlampung-karakter"
MASTER1_DB_PASS="dsmartlampung-karakter@1234"
MASTER1_PREFIX="dsk"
MASTER1_DB_PATTERN="u"     # database=u<sub>, username=d<sub>

# Master 2: dsmartlampung.com
MASTER2_NAME="dsmart"
MASTER2_DOMAIN="dsmartlampung.com"
MASTER2_USER="dsmartlampung"
MASTER2_DB="dsmartlampung"
MASTER2_DB_USER="dsmartlampung"
MASTER2_DB_PASS="dsmartlampung@1234"
MASTER2_PREFIX="ds"
MASTER2_DB_PATTERN="us"    # database=us<sub>, username=ds<sub>

# Master 3: exxamo.com
MASTER3_NAME="exxamo"
MASTER3_DOMAIN="exxamo.com"
MASTER3_USER="exxamo"
MASTER3_DB="exxamo"
MASTER3_DB_USER="exxamo"
MASTER3_DB_PASS="exxamo@1234"
MASTER3_PREFIX="ex"
MASTER3_DB_PATTERN="u"     # database=u<sub>, username=d<sub>

# Default (akan di-override saat pemilihan master)
SOURCE_DOMAIN="$MASTER1_DOMAIN"
SOURCE_USER="$MASTER1_USER"
MASTER_DB="$MASTER1_DB"
MASTER_DB_USER="$MASTER1_DB_USER"
MASTER_DB_PASS="$MASTER1_DB_PASS"
SITE_USER_PREFIX="$MASTER1_PREFIX"
DB_PATTERN="$MASTER1_DB_PATTERN"


# =====================================================
# KONFIGURASI CLONE
# =====================================================

DEFAULT_PASS="srV@1234"
PHP_VERSION="8.5"
MAX_SITE_USER_LEN=16


# =====================================================
# DAFTAR SUBDOMAIN (tanpa domain suffix)
# =====================================================

# List subdomain untuk Master 1 & 2 (karakter & dsmart)
MASTER1_SUBDOMAINS=(
"balam1" "balam2" "balam3" "balam4"
"lambar1" "lambar2" "lambar3"
"lamsel1" "lamsel2" "lamsel3" "lamsel4"
"lamteng1" "lamteng2" "lamteng3" "lamteng4" "lamteng5"
"lamtim1" "lamtim2" "lamtim3" "lamtim4"
"lamut1" "lamut2" "lamut3" "lamut4"
"mesuji1" "mesuji2" "mesuji3"
"metro1" "metro2" "metro3"
"pesawaran1" "pesawaran2" "pesawaran3"
"pesisirbar1" "pesisirbar2" "pesisirbar3"
"pringsewu1" "pringsewu2" "pringsewu3"
"tanggamus1" "tanggamus2" "tanggamus3"
"tuba1" "tuba2" "tuba3"
"tubaba1" "tubaba2" "tubaba3"
"waykanan1" "waykanan2" "waykanan3"
)

# List subdomain untuk Master 2 (dsmart) - sama dengan karakter
MASTER2_SUBDOMAINS=("${MASTER1_SUBDOMAINS[@]}")

# List subdomain untuk Master 3 (exxamo)
MASTER3_SUBDOMAINS=(
"s1" "s2" "s3" "s4"
)

# Subdomain aktif (default = master 1)
SUBDOMAINS=("${MASTER1_SUBDOMAINS[@]}")

# Generate DOMAINS berdasarkan master yang aktif
DOMAINS=()
for SUB in "${SUBDOMAINS[@]}"; do
    DOMAINS+=("${SUB}.${SOURCE_DOMAIN}")
done


# =====================================================
# PILIH MASTER DOMAIN
# =====================================================

select_master() {
    echo ""
    echo -e "${CYAN}============================================${NC}"
    echo -e "${CYAN}     PILIH MASTER DOMAIN${NC}"
    echo -e "${CYAN}============================================${NC}"
    echo ""
    echo -e "  ${GREEN}1)${NC} ${MASTER1_DOMAIN}"
    echo -e "     User: ${MASTER1_USER}"
    echo -e "     DB:   ${MASTER1_DB}"
    echo -e "     PREFIX: ${MASTER1_PREFIX}"
    echo ""
    echo -e "  ${GREEN}2)${NC} ${MASTER2_DOMAIN}"
    echo -e "     User: ${MASTER2_USER}"
    echo -e "     DB:   ${MASTER2_DB}"
    echo -e "     PREFIX: ${MASTER2_PREFIX}"
    echo ""
    echo -e "  ${GREEN}3)${NC} ${MASTER3_DOMAIN}"
    echo -e "     User: ${MASTER3_USER}"
    echo -e "     DB:   ${MASTER3_DB}"
    echo -e "     PREFIX: ${MASTER3_PREFIX}"
    echo ""
    echo -e "${CYAN}--------------------------------------------${NC}"
    read -r -p "Pilih master [1/2/3]: " MASTER_CHOICE

    case "$MASTER_CHOICE" in
        1)
            SOURCE_DOMAIN="$MASTER1_DOMAIN"
            SOURCE_USER="$MASTER1_USER"
            MASTER_DB="$MASTER1_DB"
            MASTER_DB_USER="$MASTER1_DB_USER"
            MASTER_DB_PASS="$MASTER1_DB_PASS"
            SITE_USER_PREFIX="$MASTER1_PREFIX"
            DB_PATTERN="$MASTER1_DB_PATTERN"
            SUBDOMAINS=("${MASTER1_SUBDOMAINS[@]}")
            ;;
        2)
            SOURCE_DOMAIN="$MASTER2_DOMAIN"
            SOURCE_USER="$MASTER2_USER"
            MASTER_DB="$MASTER2_DB"
            MASTER_DB_USER="$MASTER2_DB_USER"
            MASTER_DB_PASS="$MASTER2_DB_PASS"
            SITE_USER_PREFIX="$MASTER2_PREFIX"
            DB_PATTERN="$MASTER2_DB_PATTERN"
            SUBDOMAINS=("${MASTER2_SUBDOMAINS[@]}")
            ;;
        3)
            SOURCE_DOMAIN="$MASTER3_DOMAIN"
            SOURCE_USER="$MASTER3_USER"
            MASTER_DB="$MASTER3_DB"
            MASTER_DB_USER="$MASTER3_DB_USER"
            MASTER_DB_PASS="$MASTER3_DB_PASS"
            SITE_USER_PREFIX="$MASTER3_PREFIX"
            DB_PATTERN="$MASTER3_DB_PATTERN"
            SUBDOMAINS=("${MASTER3_SUBDOMAINS[@]}")
            ;;
        *)
            echo -e "${RED}Pilihan tidak valid!${NC}"
            exit 1
            ;;
    esac

    # Rebuild DOMAINS list
    DOMAINS=()
    for SUB in "${SUBDOMAINS[@]}"; do
        DOMAINS+=("${SUB}.${SOURCE_DOMAIN}")
    done

    echo ""
    echo -e "${GREEN}Master aktif: ${SOURCE_DOMAIN}${NC}"
    echo -e "${GREEN}User: ${SOURCE_USER}${NC}"
    echo -e "${GREEN}DB: ${MASTER_DB}${NC}"
    echo -e "${GREEN}PREFIX: ${SITE_USER_PREFIX}${NC}"
    sleep 1
}


# =====================================================
# CEK ROOT
# =====================================================

if [[ "$EUID" -ne 0 ]]; then
    echo -e "${RED}ERROR: Script harus dijalankan sebagai ROOT.${NC}"
    echo "Gunakan: sudo bash $0"
    exit 1
fi


# =====================================================
# CEK & INSTALL DEPENDENCY
# =====================================================

check_command() {
    command -v "$1" >/dev/null 2>&1
}

MISSING_PACKAGES=()
check_command rsync || MISSING_PACKAGES+=("rsync")
check_command dos2unix || MISSING_PACKAGES+=("dos2unix")

if [[ "${#MISSING_PACKAGES[@]}" -gt 0 ]]; then
    echo "Install paket: ${MISSING_PACKAGES[*]}"
    apt-get update -qq
    apt-get install -y -qq "${MISSING_PACKAGES[@]}" >/dev/null 2>&1
fi

for CMD in rsync dos2unix clpctl; do
    if ! check_command "$CMD"; then
        echo -e "${RED}ERROR: Command '$CMD' tidak ditemukan.${NC}"
        exit 1
    fi
done


# =====================================================
# FUNGSI GENERATE SITE USER
# =====================================================

sanitize_name() {
    local DOMAIN="$1"
    local NAME="${DOMAIN%%.*}"
    NAME="${NAME,,}"
    NAME="$(printf '%s' "$NAME" | tr -cd 'a-z0-9')"
    [[ -z "$NAME" ]] && { echo "ERROR: Nama domain tidak valid: $DOMAIN" >&2; return 1; }
    echo "$NAME"
}

make_site_user() {
    local DOMAIN="$1"
    local BASE
    local MAX_BASE_LENGTH

    BASE="$(sanitize_name "$DOMAIN")" || return 1
    MAX_BASE_LENGTH=$((MAX_SITE_USER_LEN - ${#SITE_USER_PREFIX}))

    (( MAX_BASE_LENGTH <= 0 )) && { echo "ERROR: Konfigurasi Site User tidak valid." >&2; return 1; }

    BASE="${BASE:0:MAX_BASE_LENGTH}"
    echo "${SITE_USER_PREFIX}${BASE}"
}


# =====================================================
# FUNGSI CEK STATUS WEBSITE
# =====================================================

get_site_status() {
    local DOMAIN="$1"
    local SITE_USER
    local DEST_ROOT
    local ENV_FILE

    SITE_USER="$(make_site_user "$DOMAIN" 2>/dev/null)" || { echo "INVALID"; return; }
    DEST_ROOT="/home/${SITE_USER}/htdocs/${DOMAIN}"
    ENV_FILE="${DEST_ROOT}/.env"

    # Cek site user ada
    if ! id "$SITE_USER" >/dev/null 2>&1; then
        echo "NOT_CREATED"
        return
    fi

    # Cek folder ada
    if [[ ! -d "$DEST_ROOT" ]]; then
        echo "NO_FOLDER"
        return
    fi

    # Cek .env
    local ENV_OK="NO"
    if [[ -f "$ENV_FILE" ]]; then
        grep -q "database.default.database" "$ENV_FILE" 2>/dev/null && ENV_OK="YES"
    fi

    # Cek SSL (file sertifikat ada di salah satu path)
    local SSL_OK="NO"
    [[ -n "$(find_domain_cert "$DOMAIN")" ]] && SSL_OK="YES"

    # Cek permission
    local PERM_OK="NO"
    local SITE_OWNER
    SITE_OWNER="$(stat -c '%U' "$DEST_ROOT" 2>/dev/null || echo "unknown")"
    [[ "$SITE_OWNER" == "$SITE_USER" ]] && PERM_OK="YES"

    # Summary
    if [[ "$ENV_OK" == "YES" ]] && [[ "$SSL_OK" == "YES" ]] && [[ "$PERM_OK" == "YES" ]]; then
        echo "COMPLETE"
    elif [[ "$ENV_OK" == "YES" ]]; then
        echo "PARTIAL"
    else
        echo "INCOMPLETE"
    fi
}

get_site_env_status() {
    local DOMAIN="$1"
    local SITE_USER
    local DEST_ROOT
    local ENV_FILE

    SITE_USER="$(make_site_user "$DOMAIN" 2>/dev/null)" || { echo "N/A"; return; }
    DEST_ROOT="/home/${SITE_USER}/htdocs/${DOMAIN}"
    ENV_FILE="${DEST_ROOT}/.env"

    if ! id "$SITE_USER" >/dev/null 2>&1; then echo "N/A"; return; fi
    if [[ ! -d "$DEST_ROOT" ]]; then echo "N/A"; return; fi

    if [[ -f "$ENV_FILE" ]] && grep -q "database.default.database" "$ENV_FILE" 2>/dev/null; then
        echo "OK"
    elif [[ -f "$ENV_FILE" ]]; then
        echo "BAD"
    else
        echo "MISS"
    fi
}

# Cari file sertifikat domain di lokasi lokal (CloudPanel + Let's Encrypt)
find_domain_cert() {
    local DOMAIN="$1"
    if [[ -f "/etc/nginx/ssl-certificates/${DOMAIN}.crt" ]]; then
        echo "/etc/nginx/ssl-certificates/${DOMAIN}.crt"
    elif [[ -f "/etc/letsencrypt/live/${DOMAIN}/fullchain.pem" ]]; then
        echo "/etc/letsencrypt/live/${DOMAIN}/fullchain.pem"
    fi
}

# Status SSL: YES jika ada sertifikat / config nginx
get_site_ssl_status() {
    local DOMAIN="$1"
    local SITE_USER
    local DEST_ROOT

    SITE_USER="$(make_site_user "$DOMAIN" 2>/dev/null)" || { echo "N/A"; return; }
    DEST_ROOT="/home/${SITE_USER}/htdocs/${DOMAIN}"

    if ! id "$SITE_USER" >/dev/null 2>&1; then echo "N/A"; return; fi
    if [[ ! -d "$DEST_ROOT" ]]; then echo "N/A"; return; fi

    if [[ -n "$(find_domain_cert "$DOMAIN")" ]]; then
        echo "YES"; return
    fi

    if grep -q "ssl_certificate" "/etc/nginx/sites-enabled/${DOMAIN}.conf" 2>/dev/null; then
        echo "YES"; return
    fi

    echo "NO"
}

# Status Let's Encrypt: LE jika sertifikat ada di lokal DAN issuer-nya Let's Encrypt
get_site_le_status() {
    local DOMAIN="$1"
    local CERT ISSUER

    CERT="$(find_domain_cert "$DOMAIN")"
    if [[ -z "$CERT" ]]; then
        echo "NO"; return
    fi

    ISSUER="$(openssl x509 -in "$CERT" -issuer -noout 2>/dev/null)"
    if [[ "$ISSUER" == *"Let's Encrypt"* ]]; then
        echo "LE"; return
    fi

    echo "CERT"
}

get_site_folder_status() {
    local DOMAIN="$1"
    local SITE_USER
    local DEST_ROOT

    SITE_USER="$(make_site_user "$DOMAIN" 2>/dev/null)" || { echo "N/A"; return; }
    DEST_ROOT="/home/${SITE_USER}/htdocs/${DOMAIN}"

    if ! id "$SITE_USER" >/dev/null 2>&1; then echo "N/A"; return; fi
    [[ -d "$DEST_ROOT" ]] && { echo "YES"; return; }
    echo "NO"
}

needs_update_check() {
    local DOMAIN="$1"
    local SITE_USER
    local SRC_ROOT
    local DEST_ROOT

    SITE_USER="$(make_site_user "$DOMAIN" 2>/dev/null)" || return 1
    SRC_ROOT="/home/${SOURCE_USER}/htdocs/${SOURCE_DOMAIN}"
    DEST_ROOT="/home/${SITE_USER}/htdocs/${DOMAIN}"

    [[ ! -d "$DEST_ROOT" ]] && return 1
    [[ ! -d "$SRC_ROOT" ]] && return 1

    # Bandingkan file index.php timestamp
    local SRC_INDEX DEST_INDEX
    SRC_INDEX="$SRC_ROOT/index.php"
    DEST_INDEX="$DEST_ROOT/index.php"

    [[ ! -f "$SRC_INDEX" ]] && SRC_INDEX="$SRC_ROOT/public/index.php"
    [[ ! -f "$DEST_INDEX" ]] && DEST_INDEX="$DEST_ROOT/public/index.php"

    [[ ! -f "$SRC_INDEX" ]] && return 1
    [[ ! -f "$DEST_INDEX" ]] && return 0

    local SRC_MTIME DEST_MTIME
    SRC_MTIME="$(stat -c '%Y' "$SRC_INDEX" 2>/dev/null || echo 0)"
    DEST_MTIME="$(stat -c '%Y' "$DEST_INDEX" 2>/dev/null || echo 0)"

    (( SRC_MTIME > DEST_MTIME )) && return 0
    return 1
}


# =====================================================
# FUNGSI PARSE INPUT
# =====================================================

parse_selection() {
    local INPUT="$1"
    SELECTED=()
    declare -A SEEN_INDEX

    IFS=',' read -ra PARTS <<< "$INPUT"

    for PART in "${PARTS[@]}"; do
        PART="${PART//[[:space:]]/}"

        if [[ "$PART" =~ ^[0-9]+-[0-9]+$ ]]; then
            local START="${PART%-*}"
            local END="${PART#*-}"
            local TEMP

            (( START > END )) && { TEMP="$START"; START="$END"; END="$TEMP"; }

            for ((i=START; i<=END; i++)); do
                if (( i >= 1 && i <= ${#DOMAINS[@]} )) && [[ -z "${SEEN_INDEX[$i]+x}" ]]; then
                    SELECTED+=("$i")
                    SEEN_INDEX[$i]=1
                fi
            done

        elif [[ "$PART" =~ ^[0-9]+$ ]]; then
            if (( PART >= 1 && PART <= ${#DOMAINS[@]} )) && [[ -z "${SEEN_INDEX[$PART]+x}" ]]; then
                SELECTED+=("$PART")
                SEEN_INDEX[$PART]=1
            fi
        fi
    done

    [[ "${#SELECTED[@]}" -eq 0 ]] && return 1
    return 0
}


# =====================================================
# FUNGSI SELECT DOMAINS
# =====================================================

select_domains() {
    echo
    echo "=========================================================================="
    echo "                          DAFTAR DOMAIN"
    echo "=========================================================================="
    echo
    printf "%-4s %-35s %-16s %-8s %-8s %-8s %-8s %-10s\n" \
        "NO" "DOMAIN" "USER" "FOLDER" "ENV" "SSL" "LE" "STATUS"
    echo "--------------------------------------------------------------------------"

    local NO=1
    for DOMAIN in "${DOMAINS[@]}"; do
        local SITE_USER
        SITE_USER="$(make_site_user "$DOMAIN" 2>/dev/null)" || SITE_USER="?"

        local FOLDER ENV SSL LE STATUS
        FOLDER="$(get_site_folder_status "$DOMAIN")"
        ENV="$(get_site_env_status "$DOMAIN")"
        SSL="$(get_site_ssl_status "$DOMAIN")"
        LE="$(get_site_le_status "$DOMAIN")"
        STATUS="$(get_site_status "$DOMAIN")"

        printf "%-4s %-35s %-16s %-8s %-8s %-8s %-8s %-10s\n" \
            "$NO" "$DOMAIN" "$SITE_USER" "$FOLDER" "$ENV" "$SSL" "$LE" "$STATUS"

        NO=$((NO + 1))
    done

    echo "--------------------------------------------------------------------------"
    echo
    echo "Contoh: 1, 1-5, 1,3,5, 1-3,7,10-12"
    echo

    read -r -p "Pilih domain: " INPUT

    if ! parse_selection "$INPUT"; then
        echo -e "${RED}Pilihan tidak valid.${NC}"
        return 1
    fi

    echo
    echo "Terpilih:"
    for CHOICE in "${SELECTED[@]}"; do
        echo " ${DOMAINS[$((CHOICE - 1))]}"
    done

    return 0
}


# =====================================================
# FUNGSI REPLACE DOMAIN
# =====================================================

replace_domain_in_files() {
    local DEST_ROOT="$1"
    local DOMAIN="$2"

    while IFS= read -r -d '' FILE; do
        if grep -FIlq "$SOURCE_DOMAIN" "$FILE" 2>/dev/null; then
            sed -i "s|${SOURCE_DOMAIN}|${DOMAIN}|g" "$FILE"
        fi
    done < <(find "$DEST_ROOT" -type f \
        -not -path "*/vendor/*" \
        -not -name ".env" \
        -print0 2>/dev/null)
}


# =====================================================
# FUNGSI SET .ENV VALUE
# =====================================================

set_env_value() {
    local ENV_FILE="$1"
    local KEY="$2"
    local VALUE="$3"
    local KEY_REGEX="${KEY//./\\.}"

    if grep -qE "^[#[:space:]]*${KEY_REGEX}[[:space:]]*=" "$ENV_FILE" 2>/dev/null; then
        sed -i -E "s|^[#[:space:]]*${KEY_REGEX}[[:space:]]*=.*|${KEY} = ${VALUE}|g" "$ENV_FILE"
    else
        printf "\n%s = %s\n" "$KEY" "$VALUE" >> "$ENV_FILE"
    fi
}


# =====================================================
# FUNGSI KONFIGURASI .ENV
# =====================================================

configure_env() {
    local ENV_FILE="$1"
    local DOMAIN="$2"

    if [[ ! -f "$ENV_FILE" ]]; then
        local ENV_TEMPLATE="${ENV_FILE%/.env}/env"
        if [[ -f "$ENV_TEMPLATE" ]]; then
            cp "$ENV_TEMPLATE" "$ENV_FILE"
        else
            echo -e "${RED}File .env template tidak ditemukan.${NC}"
            return 1
        fi
    fi

    dos2unix "$ENV_FILE" >/dev/null 2>&1 || true

    set_env_value "$ENV_FILE" "app.baseURL" "https://${DOMAIN}/"
    set_env_value "$ENV_FILE" "database.default.hostname" "localhost"
    set_env_value "$ENV_FILE" "database.default.database" "$MASTER_DB"
    set_env_value "$ENV_FILE" "database.default.username" "$MASTER_DB_USER"
    set_env_value "$ENV_FILE" "database.default.password" "$MASTER_DB_PASS"
    set_env_value "$ENV_FILE" "database.default.DBDriver" "MySQLi"

    echo -e "${GREEN}.env dikonfigurasi untuk $DOMAIN${NC}"
    return 0
}


# =====================================================
# FUNGSI MERGE .ENV (TAMBAH KEY YANG BELUM ADA, TIDAK MENIMPA)
# =====================================================

env_has_key() {
    local ENV_FILE="$1"
    local KEY="$2"
    local KEY_REGEX="${KEY//./\\.}"
    grep -qE "^[#[:space:]]*${KEY_REGEX}[[:space:]]*=" "$ENV_FILE" 2>/dev/null
}

merge_env_missing() {
    local SRC_ENV="$1"
    local DEST_ENV="$2"

    if [[ ! -f "$SRC_ENV" ]]; then
        echo -e "${YELLOW}Source .env tidak ditemukan, skip merge.${NC}"
        return 0
    fi

    if [[ ! -f "$DEST_ENV" ]]; then
        echo -e "${YELLOW}Dest .env tidak ditemukan, skip merge.${NC}"
        return 0
    fi

    dos2unix "$SRC_ENV" "$DEST_ENV" >/dev/null 2>&1 || true

    local ADDED=0
    local KEY VALUE

    while IFS= read -r LINE; do
        [[ -z "$LINE" ]] && continue
        [[ "$LINE" =~ ^[[:space:]]*# ]] && continue

        if [[ "$LINE" =~ ^[[:space:]]*([A-Za-z0-9_.]+)[[:space:]]*=[[:space:]]*(.*)$ ]]; then
            KEY="${BASH_REMATCH[1]}"
            VALUE="${BASH_REMATCH[2]}"
        else
            continue
        fi

        if ! env_has_key "$DEST_ENV" "$KEY"; then
            printf "\n%s = %s\n" "$KEY" "$VALUE" >> "$DEST_ENV"
            ADDED=$((ADDED + 1))
            echo -e "${CYAN}  Tambah key baru: ${KEY}${NC}"
        fi
    done < "$SRC_ENV"

    if (( ADDED > 0 )); then
        echo -e "${GREEN}Env merged: $ADDED key baru ditambahkan (nilai lama aman).${NC}"
    else
        echo "Env sudah lengkap, tidak ada key baru."
    fi

    return 0
}


# =====================================================
# FUNGSI CLONE DOMAIN
# =====================================================

clone_domain() {
    local DOMAIN="$1"
    local SITE_USER
    local SRC_ROOT
    local DEST_ROOT
    local ENV_FILE

    SITE_USER="$(make_site_user "$DOMAIN")" || return 1
    SRC_ROOT="/home/${SOURCE_USER}/htdocs/${SOURCE_DOMAIN}"
    DEST_ROOT="/home/${SITE_USER}/htdocs/${DOMAIN}"
    ENV_FILE="${DEST_ROOT}/.env"

    echo
    echo "=============================================================="
    echo "  CLONE: $DOMAIN"
    echo "=============================================================="

    # Validasi source
    if [[ ! -d "$SRC_ROOT" ]]; then
        echo -e "${RED}ERROR: Source tidak ditemukan: $SRC_ROOT${NC}"
        return 1
    fi

    # Cek sudah ada
    if id "$SITE_USER" >/dev/null 2>&1; then
        echo -e "${YELLOW}SKIP: Site user '$SITE_USER' sudah ada.${NC}"
        return 0
    fi

    if [[ -d "$DEST_ROOT" ]]; then
        echo -e "${YELLOW}SKIP: Folder '$DEST_ROOT' sudah ada.${NC}"
        return 0
    fi

    # Buat website CloudPanel
    echo "Membuat website..."
    if ! clpctl site:add:php \
        --domainName="$DOMAIN" \
        --phpVersion="$PHP_VERSION" \
        --vhostTemplate="CodeIgniter 4" \
        --siteUser="$SITE_USER" \
        --siteUserPassword="$DEFAULT_PASS"; then
        echo -e "${RED}Gagal membuat website.${NC}"
        return 1
    fi

    # Copy file
    echo "Copy file dari master..."
    if ! rsync -av "$SRC_ROOT/" "$DEST_ROOT/"; then
        echo -e "${RED}Gagal copy. Rollback...${NC}"
        clpctl site:delete --domainName="$DOMAIN" --force >/dev/null 2>&1 || true
        return 1
    fi

    # Replace domain
    replace_domain_in_files "$DEST_ROOT" "$DOMAIN"

    # Konfigurasi .env
    if ! configure_env "$ENV_FILE" "$DOMAIN"; then
        echo -e "${RED}Gagal .env. Rollback...${NC}"
        clpctl site:delete --domainName="$DOMAIN" --force >/dev/null 2>&1 || true
        return 1
    fi

    # Permission
    chown -R "$SITE_USER:$SITE_USER" "/home/$SITE_USER"
    if [[ -d "$DEST_ROOT/writable" ]]; then
        chown -R "$SITE_USER:$SITE_USER" "$DEST_ROOT/writable"
        chmod -R 775 "$DEST_ROOT/writable"
    fi

    echo -e "${GREEN}==============================================================${NC}"
    echo -e "${GREEN}  CLONE BERHASIL: $DOMAIN${NC}"
    echo -e "${GREEN}==============================================================${NC}"
    return 0
}


# =====================================================
# FUNGSI UPDATE DOMAIN
# =====================================================

update_domain() {
    local DOMAIN="$1"
    local SITE_USER
    local SRC_ROOT
    local DEST_ROOT
    local ENV_FILE
    local BACKUP_DIR

    SITE_USER="$(make_site_user "$DOMAIN" 2>/dev/null)" || return 1
    SRC_ROOT="/home/${SOURCE_USER}/htdocs/${SOURCE_DOMAIN}"
    DEST_ROOT="/home/${SITE_USER}/htdocs/${DOMAIN}"
    ENV_FILE="${DEST_ROOT}/.env"

    echo
    echo "=============================================================="
    echo "  UPDATE: $DOMAIN"
    echo "=============================================================="

    if [[ ! -d "$SRC_ROOT" ]]; then
        echo -e "${RED}ERROR: Source tidak ditemukan.${NC}"
        return 1
    fi

    if ! id "$SITE_USER" >/dev/null 2>&1; then
        echo -e "${RED}ERROR: Site user '$SITE_USER' tidak ada.${NC}"
        return 1
    fi

    if [[ ! -d "$DEST_ROOT" ]]; then
        echo -e "${RED}ERROR: Folder target tidak ada.${NC}"
        return 1
    fi

    # Backup
    BACKUP_DIR="/home/${SITE_USER}/backup_$(date +%Y%m%d_%H%M%S)"
    echo "Backup ke: $BACKUP_DIR"
    mkdir -p "$BACKUP_DIR"
    [[ -f "$ENV_FILE" ]] && cp "$ENV_FILE" "$BACKUP_DIR/.env.backup"

    # Sync file utama (kecuali vendor, .env)
    echo "Sync file dari master..."
    if rsync -av \
        --exclude='vendor/' \
        --exclude='.env' \
        --exclude='writable/' \
        "$SRC_ROOT/" \
        "$DEST_ROOT/"; then
        echo -e "${GREEN}File synced.${NC}"
    else
        echo -e "${RED}Gagal sync.${NC}"
        return 1
    fi

    # Tidak sync writable runtime (session, logs, debugbar, cache) — biarkan tiap situs punya sendiri.
    # Ganti domain
    replace_domain_in_files "$DEST_ROOT" "$DOMAIN"

    # Permission
    chown -R "$SITE_USER:$SITE_USER" "/home/$SITE_USER"
    if [[ -d "$DEST_ROOT/writable" ]]; then
        chown -R "$SITE_USER:$SITE_USER" "$DEST_ROOT/writable"
        chmod -R 775 "$DEST_ROOT/writable"
    fi

    echo -e "${GREEN}==============================================================${NC}"
    echo -e "${GREEN}  UPDATE BERHASIL: $DOMAIN${NC}"
    echo -e "${GREEN}==============================================================${NC}"
    return 0
}


# =====================================================
# FUNGSI FIX ISSUES
# =====================================================

fix_website() {
    local DOMAIN="$1"
    local SITE_USER
    local DEST_ROOT
    local ENV_FILE

    SITE_USER="$(make_site_user "$DOMAIN" 2>/dev/null)" || return 1
    DEST_ROOT="/home/${SITE_USER}/htdocs/${DOMAIN}"
    ENV_FILE="${DEST_ROOT}/.env"

    echo
    echo "=============================================================="
    echo "  FIX: $DOMAIN"
    echo "=============================================================="

    if ! id "$SITE_USER" >/dev/null 2>&1; then
        echo -e "${RED}Site user '$SITE_USER' tidak ada. Skip.${NC}"
        return 1
    fi

    # Fix permission
    local SITE_OWNER
    SITE_OWNER="$(stat -c '%U' "$DEST_ROOT" 2>/dev/null || echo "unknown")"
    if [[ "$SITE_OWNER" != "$SITE_USER" ]]; then
        echo "Fix permission (owner: $SITE_OWNER -> $SITE_USER)..."
        chown -R "$SITE_USER:$SITE_USER" "/home/$SITE_USER"
        echo -e "${GREEN}Permission fixed.${NC}"
    fi

    # Fix .env - cek apakah domain berulang
    if [[ -f "$ENV_FILE" ]]; then
        local NEED_FIX=false

        # Cek pola domain berulang (contoh: balam1.balam1.karakter.dsmartlampung.com)
        local DOMAIN_PART="${DOMAIN#*.}"
        if grep -qE "([a-z0-9]+\.){2,}${DOMAIN_PART}" "$ENV_FILE" 2>/dev/null; then
            echo -e "${YELLOW}Detect .env domain berulang!${NC}"
            NEED_FIX=true
        fi

        # Cek apakah baseURL salah
        local CURRENT_URL
        CURRENT_URL="$(grep -oP 'app\.baseURL\s*=\s*\K.*' "$ENV_FILE" 2>/dev/null || echo "")"
        local EXPECTED_URL="https://${DOMAIN}/"

        if [[ "$CURRENT_URL" != "$EXPECTED_URL" ]]; then
            echo -e "${YELLOW}app.baseURL salah: $CURRENT_URL${NC}"
            NEED_FIX=true
        fi

        if [[ "$NEED_FIX" == true ]]; then
            echo "Perbaiki .env..."
            configure_env "$ENV_FILE" "$DOMAIN"
        fi
    else
        echo "Buat .env baru..."
        configure_env "$ENV_FILE" "$DOMAIN"
    fi

    # Fix writable
    if [[ -d "$DEST_ROOT/writable" ]]; then
        chown -R "$SITE_USER:$SITE_USER" "$DEST_ROOT/writable"
        chmod -R 775 "$DEST_ROOT/writable"
    fi

    echo -e "${GREEN}==============================================================${NC}"
    echo -e "${GREEN}  FIX SELESAI: $DOMAIN${NC}"
    echo -e "${GREEN}==============================================================${NC}"
    return 0
}


# =====================================================
# FUNGSI INSTALL SSL
# =====================================================

install_ssl_domain() {
    local DOMAIN="$1"
    local AUTO="${2:-}"

    echo
    echo "=============================================================="
    echo "  INSTALL SSL: $DOMAIN"
    echo "=============================================================="
    echo "Pastikan DNS sudah mengarah ke server."
    echo

    if [[ "$AUTO" != "auto" ]]; then
        read -r -p "Lanjutkan? (y/n): " CONFIRM
        [[ ! "$CONFIRM" =~ ^[Yy]$ ]] && { echo "Dibatalkan."; return 0; }
    fi

    if clpctl lets-encrypt:install:certificate --domainName="$DOMAIN"; then
        echo -e "${GREEN}SSL BERHASIL: https://$DOMAIN${NC}"
        return 0
    else
        echo -e "${RED}SSL GAGAL: $DOMAIN${NC}"
        return 1
    fi
}


# =====================================================
# FUNGSI HAPUS DOMAIN
# =====================================================

delete_domain() {
    local DOMAIN="$1"
    local SITE_USER

    SITE_USER="$(make_site_user "$DOMAIN" 2>/dev/null)" || return 1

    echo
    echo "=============================================================="
    echo "  HAPUS: $DOMAIN (user: $SITE_USER)"
    echo "=============================================================="
    echo -e "${YELLOW}Database utama TIDAK akan dihapus: $MASTER_DB${NC}"
    echo
    echo "Ketik HAPUS untuk konfirmasi:"

    read -r -p "> " CONFIRM
    [[ "$CONFIRM" != "HAPUS" ]] && { echo "Dibatalkan."; return 0; }

    if clpctl site:delete --domainName="$DOMAIN" --force; then
        echo -e "${GREEN}BERHASIL DIHAPUS: $DOMAIN${NC}"
        return 0
    else
        echo -e "${RED}GAGAL HAPUS: $DOMAIN${NC}"
        return 1
    fi
}


# =====================================================
# MENU CLONE
# =====================================================

menu_clone() {
    clear
    echo "=============================================================="
    echo "  CLONE WEBSITE -> DATABASE UTAMA"
    echo "=============================================================="
    echo
    echo "DB: $MASTER_DB / $MASTER_DB_USER"
    echo

    if ! select_domains; then
        read -r -p "Tekan ENTER..."; return
    fi

    echo
    read -r -p "Lanjutkan clone? (y/n): " CONFIRM
    [[ ! "$CONFIRM" =~ ^[Yy]$ ]] && { echo "Dibatalkan."; read -r -p "Tekan ENTER..."; return; }

    local OK=0 FAIL=0
    for CHOICE in "${SELECTED[@]}"; do
        if clone_domain "${DOMAINS[$((CHOICE - 1))]}"; then
            OK=$((OK + 1))
        else
            FAIL=$((FAIL + 1))
        fi
    done

    echo
    echo "=============================================================="
    echo "  SELESAI: $OK berhasil, $FAIL gagal"
    echo "=============================================================="
    read -r -p "Tekan ENTER..."
}


# =====================================================
# MENU UPDATE
# =====================================================

menu_update() {
    clear
    echo "=============================================================="
    echo "  UPDATE WEBSITE DARI MASTER"
    echo "=============================================================="
    echo
    echo "Sync file dari master, kecuali vendor/ writable/ .env"
    echo "Merge .env: tambah key baru dari master (tanpa menimpa yang sudah ada)"
    echo

    echo "Pilih:"
    echo "1) Update semua yang sudah ada"
    echo "2) Pilih tertentu"
    echo "0) Kembali"
    echo
    read -r -p "Pilihan: " CHOICE

    case "$CHOICE" in
        1)
            local OK=0 FAIL=0 SKIP=0
            for DOMAIN in "${DOMAINS[@]}"; do
                local SU
                SU="$(make_site_user "$DOMAIN" 2>/dev/null)" || continue
                if ! id "$SU" >/dev/null 2>&1; then
                    SKIP=$((SKIP + 1))
                    continue
                fi
                if update_domain "$DOMAIN"; then
                    OK=$((OK + 1))
                else
                    FAIL=$((FAIL + 1))
                fi
            done
            echo
            echo "Selesai: $OK ok, $FAIL gagal, $SKIP skip"
            ;;
        2)
            if ! select_domains; then
                read -r -p "Tekan ENTER..."; return
            fi
            for CHOICE2 in "${SELECTED[@]}"; do
                update_domain "${DOMAINS[$((CHOICE2 - 1))]}"
            done
            ;;
        0) return ;;
    esac

    echo
    read -r -p "Tekan ENTER..."
}


# =====================================================
# MENU FIX
# =====================================================

menu_fix() {
    clear
    echo "=============================================================="
    echo "  FIX WEBSITE ISSUES"
    echo "=============================================================="

    if ! select_domains; then
        read -r -p "Tekan ENTER..."; return
    fi

    echo
    read -r -p "Fix issues? (y/n): " CONFIRM
    [[ ! "$CONFIRM" =~ ^[Yy]$ ]] && { echo "Dibatalkan."; return; }

    for CHOICE in "${SELECTED[@]}"; do
        fix_website "${DOMAINS[$((CHOICE - 1))]}"
    done

    echo
    read -r -p "Tekan ENTER..."
}


# =====================================================
# MENU SSL
# =====================================================

menu_ssl() {
    clear
    echo "=============================================================="
    echo "  INSTALL SSL LET'S ENCRYPT"
    echo "=============================================================="
    echo
    echo "Pilih:"
    echo "1) Install LE untuk semua yang BELUM punya Let's Encrypt (auto)"
    echo "2) Pilih manual"
    echo "0) Batal"
    echo
    read -r -p "Pilihan: " SSL_CHOICE

    case "$SSL_CHOICE" in
        1)
            local TO_INSTALL=()
            for DOMAIN in "${DOMAINS[@]}"; do
                local SU
                SU="$(make_site_user "$DOMAIN" 2>/dev/null)" || continue
                if id "$SU" >/dev/null 2>&1 && [[ -d "/home/${SU}/htdocs/${DOMAIN}" ]] && [[ "$(get_site_le_status "$DOMAIN")" != "LE" ]]; then
                    TO_INSTALL+=("$DOMAIN")
                fi
            done

            if [[ "${#TO_INSTALL[@]}" -eq 0 ]]; then
                echo -e "${GREEN}Semua domain sudah punya Let's Encrypt.${NC}"
                read -r -p "Tekan ENTER..."
                return
            fi

            echo
            echo "Domain yang BELUM Let's Encrypt (${#TO_INSTALL[@]}):"
            for D in "${TO_INSTALL[@]}"; do
                echo "  - $D ($(get_site_le_status "$D"))"
            done
            echo
            read -r -p "Install LE untuk semua di atas? (y/n): " CONFIRM
            [[ ! "$CONFIRM" =~ ^[Yy]$ ]] && { echo "Dibatalkan."; return; }

            local OK=0 FAIL=0
            for D in "${TO_INSTALL[@]}"; do
                if install_ssl_domain "$D" auto; then
                    OK=$((OK + 1))
                else
                    FAIL=$((FAIL + 1))
                fi
            done
            echo
            echo "SELESAI: $OK berhasil, $FAIL gagal"
            ;;
        2)
            if ! select_domains; then
                read -r -p "Tekan ENTER..."; return
            fi

            echo
            read -r -p "Install SSL? (y/n): " CONFIRM
            [[ ! "$CONFIRM" =~ ^[Yy]$ ]] && { echo "Dibatalkan."; return; }

            for CHOICE in "${SELECTED[@]}"; do
                install_ssl_domain "${DOMAINS[$((CHOICE - 1))]}"
            done
            ;;
        0) return ;;
        *) echo -e "${RED}Pilihan tidak valid.${NC}" ;;
    esac

    echo
    read -r -p "Tekan ENTER..."
}


# =====================================================
# MENU MAPPING
# =====================================================

menu_mapping() {
    clear
    echo "=========================================================================="
    echo "  MAPPING WEBSITE"
    echo "=========================================================================="
    echo
    echo "SOURCE : $SOURCE_DOMAIN ($SOURCE_USER)"
    echo "DB     : $MASTER_DB"
    echo "DBUSR  : $MASTER_DB_USER"
    echo
    echo "--------------------------------------------------------------------------"
    printf "%-4s %-35s %-16s\n" "NO" "DOMAIN" "USER"
    echo "--------------------------------------------------------------------------"

    local NO=1
    for DOMAIN in "${DOMAINS[@]}"; do
        local SU
        SU="$(make_site_user "$DOMAIN" 2>/dev/null)" || SU="?"
        printf "%-4s %-35s %-16s\n" "$NO" "$DOMAIN" "$SU"
        NO=$((NO + 1))
    done

    echo "=========================================================================="
    read -r -p "Tekan ENTER..."
}


# =====================================================
# MENU DELETE
# =====================================================

menu_delete() {
    clear
    echo "=============================================================="
    echo "  HAPUS WEBSITE"
    echo "=============================================================="
    echo
    echo -e "${YELLOW}Database utama TIDAK dihapus: $MASTER_DB${NC}"

    if ! select_domains; then
        read -r -p "Tekan ENTER..."; return
    fi

    for CHOICE in "${SELECTED[@]}"; do
        delete_domain "${DOMAINS[$((CHOICE - 1))]}"
    done

    echo
    read -r -p "Tekan ENTER..."
}


# =====================================================
# MENU STATUS
# =====================================================

menu_status() {
    clear
    echo "=============================================================="
    echo "  STATUS WEBSITE"
    echo "=============================================================="
    echo
    echo "SOURCE : $SOURCE_DOMAIN ($SOURCE_USER)"
    echo "DB     : $MASTER_DB"
    echo

    local TOTAL=${#DOMAINS[@]}
    local COMPLETE=0 NOT_CREATED=0 PARTIAL=0 INCOMPLETE=0 SSL_YES=0 LE_YES=0

    for DOMAIN in "${DOMAINS[@]}"; do
        local ST SSL LE
        ST="$(get_site_status "$DOMAIN")"
        SSL="$(get_site_ssl_status "$DOMAIN")"
        LE="$(get_site_le_status "$DOMAIN")"

        case "$ST" in
            COMPLETE) COMPLETE=$((COMPLETE + 1)) ;;
            NOT_CREATED) NOT_CREATED=$((NOT_CREATED + 1)) ;;
            PARTIAL) PARTIAL=$((PARTIAL + 1)) ;;
            *) INCOMPLETE=$((INCOMPLETE + 1)) ;;
        esac
        [[ "$SSL" == "YES" ]] && SSL_YES=$((SSL_YES + 1))
        [[ "$LE" == "LE" ]] && LE_YES=$((LE_YES + 1))
    done

    echo "Ringkasan:"
    echo "  Total       : $TOTAL"
    echo -e "  Lengkap     : ${GREEN}$COMPLETE${NC}"
    echo -e "  Partial     : ${YELLOW}$PARTIAL${NC}"
    echo -e "  Incomplete  : ${RED}$INCOMPLETE${NC}"
    echo -e "  Belum Buat  : ${YELLOW}$NOT_CREATED${NC}"
    echo -e "  SSL Aktif   : ${GREEN}$SSL_YES${NC}"
    echo -e "  LE Terpasang: ${GREEN}$LE_YES${NC}"
    echo
    echo "--------------------------------------------------------------------------"
    printf "%-4s %-35s %-16s %-8s %-8s %-8s %-8s %-10s\n" \
        "NO" "DOMAIN" "USER" "FOLDER" "ENV" "SSL" "LE" "STATUS"
    echo "--------------------------------------------------------------------------"

    local NO=1
    for DOMAIN in "${DOMAINS[@]}"; do
        local SU FOLDER ENV SSL LE ST
        SU="$(make_site_user "$DOMAIN" 2>/dev/null)" || SU="?"
        FOLDER="$(get_site_folder_status "$DOMAIN")"
        ENV="$(get_site_env_status "$DOMAIN")"
        SSL="$(get_site_ssl_status "$DOMAIN")"
        LE="$(get_site_le_status "$DOMAIN")"
        ST="$(get_site_status "$DOMAIN")"

        printf "%-4s %-35s %-16s %-8s %-8s %-8s %-8s %-10s\n" \
            "$NO" "$DOMAIN" "$SU" "$FOLDER" "$ENV" "$SSL" "$LE" "$ST"
        NO=$((NO + 1))
    done

    echo "--------------------------------------------------------------------------"
    echo
    read -r -p "Tekan ENTER..."
}


# =====================================================
# FUNGSI FIX FSTAB (LABEL -> UUID)
# =====================================================

fix_fstab_labels() {
    local FSTAB="/etc/fstab"
    local CHANGED=0

    if [[ ! -f "$FSTAB" ]]; then
        echo -e "${RED}fstab tidak ditemukan: $FSTAB${NC}"
        return 1
    fi

    echo ""
    echo "Memeriksa fstab (perbaiki LABEL= dan UUID= yang salah)..."

    while IFS= read -r LINE; do
        [[ -z "$LINE" ]] && continue
        [[ "$LINE" =~ ^[[:space:]]*# ]] && continue

        local DEV MP FSTYPE OPTS DUMP PASS LBL UUID REAL_DEV
        read -r DEV MP FSTYPE OPTS DUMP PASS <<< "$LINE"

        # kasus 1: LABEL=x -> cari device melalui blkid
        if [[ "$DEV" == LABEL=* ]]; then
            LBL="${DEV#LABEL=}"
            REAL_DEV="$(blkid -L "$LBL" 2>/dev/null)"
        # kasus 2: UUID yang nilainya adalah path device (salah), mis. UUID=/dev/vda1
        elif [[ "$DEV" == UUID=* ]]; then
            REAL_DEV="${DEV#UUID=}"
            [[ "$REAL_DEV" == /dev/* ]] || REAL_DEV=""
        else
            continue
        fi

        if [[ -z "$REAL_DEV" ]]; then
            echo -e "${YELLOW}  Skip: '$DEV' -> device tidak ditemukan.${NC}"
            continue
        fi

        UUID="$(blkid -s UUID -o value "$REAL_DEV" 2>/dev/null)"

        if [[ -n "$UUID" ]]; then
            sed -i "s|^${DEV//[[:space:]]/}[[:space:]]\+.*|UUID=${UUID}  ${MP}  ${FSTYPE}  ${OPTS}  ${DUMP}  ${PASS}|" "$FSTAB"
            CHANGED=$((CHANGED + 1))
            echo -e "${GREEN}  OK: $DEV -> UUID=$UUID  ($MP)${NC}"
        else
            echo -e "${YELLOW}  Skip: tidak ada UUID untuk $REAL_DEV.${NC}"
        fi
    done < "$FSTAB"

    if (( CHANGED > 0 )); then
        echo -e "${GREEN}fstab diperbaiki ($CHANGED baris).${NC}"
    else
        echo "Tidak ada perubahan fstab."
    fi

    recover_failed_mounts

    return 0
}


# =====================================================
# RECOVER FAILED MOUNTS (reset-failed + mount -a)
# =====================================================

recover_failed_mounts() {
    local FAILED_MOUNTS

    FAILED_MOUNTS="$(systemctl --state=failed --no-legend --no-pager --plain 2>/dev/null | awk '{print $1}' | grep '\.mount' | tr '\n' ' ')"
    [[ -z "${FAILED_MOUNTS//[[:space:]]/}" ]] && FAILED_MOUNTS="boot.mount"

    echo "Memulihkan mount yang gagal: ${FAILED_MOUNTS}"
    systemctl daemon-reload 2>/dev/null
    mount -a 2>&1 || true

    for FM in ${FAILED_MOUNTS}; do
        echo "  Coba perbaiki $FM..."
        systemctl reset-failed "$FM" 2>/dev/null
        systemctl start "$FM" 2>&1 || true
    done

    mount -a 2>&1 || true
    systemctl reset-failed 2>/dev/null
    systemctl daemon-reload 2>/dev/null
}


# =====================================================
# FUNGSI DIAGNOSIS TUNE UP
# =====================================================

show_tuneup_errors() {
    echo ""
    echo "===================== DIAGNOSIS ====================="
    echo "MySQL status : $(systemctl is-active mysql 2>/dev/null)"
    echo "System state : $(systemctl is-system-running 2>/dev/null)"
    echo ""
    echo ""
    echo "--- fstab bermasalah (LABEL= / UUID=/dev) ---"
    grep -E "LABEL=|UUID=/dev" /etc/fstab 2>/dev/null || echo "(tidak ada LABEL= / UUID=/dev)"
    echo ""
    echo "--- /etc/fstab ---"
    grep -Ev "^[[:space:]]*#|^[[:space:]]*$" /etc/fstab 2>/dev/null
    echo ""
    echo "--- mount penting ---"
    mount | grep -E " on /boot| on / " || echo "(boot/root tidak ter-mount)"
    echo ""
    echo "--- systemctl --state=failed ---"
    systemctl --state=failed --no-pager --no-legend
    echo ""
    echo "--- journalctl -u mysql (last 40) ---"
    journalctl -u mysql --no-pager -n 40
    echo ""
    echo "--- journalctl -u boot.mount (last 20) ---"
    journalctl -u boot.mount --no-pager -n 20 2>/dev/null
    echo ""
    echo "--- Emergency / maintenance target? ---"
    systemctl is-active emergency.service 2>/dev/null
    systemctl is-active emergency.target 2>/dev/null
    echo ""
    echo "--- dmesg OOM / killed process (terakhir) ---"
    dmesg -T 2>/dev/null | grep -iE "out of memory|killed process" | grep -iE "mysqld|mysql" | tail -5
    echo ""
    echo "--- /var/log/mysql/error.log (last 30) ---"
    tail -30 /var/log/mysql/error.log 2>/dev/null
    echo "================== END DIAGNOSIS ===================="
}


# =====================================================
# PERBAIKI MYSQL YANG OOM-KILLED
# =====================================================

fix_mysql_oom() {
    local MYSQL_CONF="/etc/mysql/mysql.conf.d/mysqld.cnf"
    local RAM_GB SAFE_BP OOM_LOG

    # Hanya anggap OOM jika ada kill mysqld dalam 5 menit terakhir
    OOM_LOG="$(journalctl -u mysql --since "5 minutes ago" --no-pager 2>/dev/null | grep -m1 "status=9/KILL")"
    [[ -z "$OOM_LOG" ]] && OOM_LOG="$(dmesg -T 2>/dev/null | grep -iE "out of memory|killed process" | grep -i mysqld | tail -1)"

    if [[ -z "$OOM_LOG" ]]; then
        echo -e "${YELLOW}MySQL mati, tapi bukan karena OOM-kill (gunakan opsi 2 untuk diagnostik).${NC}"
        return 1
    fi

    RAM_GB="$(free -g | awk '/^Mem:/{print $2}')"
    [[ ! "$RAM_GB" =~ ^[0-9]+$ ]] || (( RAM_GB == 0 )) && RAM_GB=2

    if (( RAM_GB <= 2 )); then
        SAFE_BP="512M"
    elif (( RAM_GB <= 4 )); then
        SAFE_BP="1G"
    elif (( RAM_GB <= 8 )); then
        SAFE_BP="2G"
    else
        SAFE_BP="$((RAM_GB / 4))G"
        (( RAM_GB / 4 > 4 )) && SAFE_BP="4G"
    fi

    echo -e "${RED}MySQL di-OOM-kill! Menurunkan innodb_buffer_pool_size ke ${SAFE_BP}...${NC}"

    systemctl stop mysql 2>/dev/null
    sleep 1

    if [[ -f "$MYSQL_CONF" ]]; then
        sed -i "s|^innodb_buffer_pool_size\s*=.*|innodb_buffer_pool_size = ${SAFE_BP}|" "$MYSQL_CONF"
        echo -e "${GREEN}innodb_buffer_pool_size diset ke ${SAFE_BP} di ${MYSQL_CONF}.${NC}"
    fi

    systemctl reset-failed mysql 2>/dev/null
    echo -e "${YELLOW}Memulai ulang MySQL...${NC}"
    systemctl start mysql
    sleep 4
    echo "MySQL sekarang: $(systemctl is-active mysql)"
}


# =====================================================
# MENU TUNEUP SERVER
# =====================================================

menu_tuneup() {
    clear
    echo "=============================================================="
    echo "  SMART SAFE TUNER (MySQL + PHP-FPM + Nginx)"
    echo "=============================================================="
    echo
    echo -e "${YELLOW}Menyesuaikan konfigurasi MySQL, semua PHP-FPM dan nginx.${NC}"
    echo -e "${YELLOW}Config lama akan dibackup dan auto rollback jika gagal.${NC}"
    echo

    # ============================================================
    # CEK KESEHATAN: perbaiki / cek error / kembali
    # ============================================================

    while true; do
        MYSQL_NOW="$(systemctl is-active mysql 2>/dev/null)"
        FAILED_UNITS="$(systemctl --state=failed --no-legend --no-pager --plain 2>/dev/null | awk '{print $1}' | tr '\n' ' ')"

        CRIT_FAILED=""
        NONCRIT_FAILED=""
        for U in ${FAILED_UNITS}; do
            case "$U" in
                *.mount) CRIT_FAILED="${CRIT_FAILED} ${U}" ;;
                *) NONCRIT_FAILED="${NONCRIT_FAILED} ${U}" ;;
            esac
        done

        HEALTHY=1
        [[ "$MYSQL_NOW" == "active" ]] || HEALTHY=0
        [[ -n "${CRIT_FAILED//[[:space:]]/}" ]] && HEALTHY=0

        if (( HEALTHY )); then
            if [[ -n "${NONCRIT_FAILED//[[:space:]]/}" ]]; then
                echo -e "${YELLOW}Catatan: unit non-kritis gagal (diabaikan):${NONCRIT_FAILED}${NC}"
            fi
            echo -e "${GREEN}Status OK: MySQL aktif, tidak ada mount gagal.${NC}"
            echo
            break
        fi

        echo ""
        echo -e "${RED}MASALAH TERDETEKSI:${NC}"
        echo "  MySQL       : $MYSQL_NOW"
        [[ -n "${CRIT_FAILED//[[:space:]]/}" ]] && echo -e "  Mount gagal : ${CRIT_FAILED}"
        [[ -n "${NONCRIT_FAILED//[[:space:]]/}" ]] && echo -e "  Non-kritis  : ${NONCRIT_FAILED} (diabaikan)"
        echo ""
        echo "Pilihan:"
        echo "1) Perbaiki otomatis"
        echo "2) Cek error (diagnostik)"
        echo "0) Kembali ke menu"
        echo
        read -r -p "Pilihan: " FIX_CHOICE

        case "$FIX_CHOICE" in
            1)
                # Selalu perbaiki fstab dulu (idempotent & aman), lalu start MySQL
                fix_fstab_labels
                if [[ "$(systemctl is-active emergency.target 2>/dev/null)" == "active" ]] || [[ "$(systemctl is-active emergency.service 2>/dev/null)" == "active" ]] || [[ "$(systemctl is-system-running 2>/dev/null)" == "maintenance" ]]; then
                    echo -e "${RED}System masih dalam maintenance/emergency mode. Mencoba keluar...${NC}"
                    mount -o remount,rw / 2>/dev/null
                    systemctl daemon-reload 2>/dev/null
                    systemctl reset-failed 2>/dev/null
                    systemctl start multi-user.target 2>&1 || true
                    sleep 6
                    echo "System state : $(systemctl is-system-running 2>/dev/null)"
                fi
                if [[ "$(systemctl is-active emergency.target 2>/dev/null)" == "active" ]] || [[ "$(systemctl is-active emergency.service 2>/dev/null)" == "active" ]]; then
                    echo -e "${RED}Masih di emergency mode. Coba manual:${NC}"
                    echo "  mount -o remount,rw /"
                    echo "  systemctl start multi-user.target   (atau: systemctl exit)"
                elif [[ "$MYSQL_NOW" != "active" ]]; then
                    echo -e "${YELLOW}Mencoba start MySQL...${NC}"
                    local START_OUT
                    START_OUT="$(systemctl start mysql 2>&1)"
                    sleep 3
                    echo "MySQL sekarang: $(systemctl is-active mysql)"
                    if [[ "$(systemctl is-active mysql)" != "active" ]]; then
                        if grep -qiE "dependency|transaction for mysql|failed because" <<<"$START_OUT"; then
                            echo -e "${YELLOW}MySQL gagal karena dependency (mount/system state). Periksa: systemctl --state=failed${NC}"
                        else
                            fix_mysql_oom
                        fi
                    fi
                fi
                ;;
            2)
                show_tuneup_errors
                ;;
            0)
                echo "Kembali ke menu."
                read -r -p "Tekan ENTER..."
                return
                ;;
            *)
                echo -e "${RED}Pilihan tidak valid.${NC}"
                ;;
        esac
    done

    read -r -p "Total RAM VPS (GB): " RAM
    read -r -p "Total CPU Core: " CORE

    if [[ ! "$RAM" =~ ^[0-9]+$ ]] || (( RAM < 1 )); then
        echo -e "${RED}RAM tidak valid.${NC}"
        read -r -p "Tekan ENTER..."
        return
    fi

    if [[ ! "$CORE" =~ ^[0-9]+$ ]] || (( CORE < 1 )); then
        echo -e "${RED}CPU Core tidak valid.${NC}"
        read -r -p "Tekan ENTER..."
        return
    fi

    # Pilihan versi PHP yang mau ditune (kosong = semua)
    echo
    read -r -p "Versi PHP untuk ditune (kosong = semua, contoh: 8.5 atau 8.1,8.5): " PHP_SELECT

    if [[ -n "$PHP_SELECT" ]]; then
        PHP_SELECT="$(printf '%s' "$PHP_SELECT" | tr -cd '0-9.,')"
    fi

    echo
    read -r -p "Lanjutkan tune up? (y/n): " CONFIRM
    [[ ! "$CONFIRM" =~ ^[Yy]$ ]] && { echo "Dibatalkan."; read -r -p "Tekan ENTER..."; return; }

    tuneup_server "$RAM" "$CORE" "$PHP_SELECT"

    echo
    read -r -p "Tekan ENTER..."
}


# =====================================================
# FUNGSI TUNEUP SERVER
# =====================================================

tuneup_server() {
    local RAM="$1"
    local CORE="$2"
    local PHP_SELECT="$3"

    local MYSQL_CONF="/etc/mysql/mysql.conf.d/mysqld.cnf"
    local MYSQL_DATA="/home/mysql"
    local DATE
    local PHP_VERSIONS
    local PHPVER

    DATE="$(date +%F_%H%M%S)"

    echo "================================================="
    echo "          SMART SAFE TUNER"
    echo "================================================="

    # ============================================================
    # DETECT PHP VERSION
    # ============================================================

    echo ""
    echo "[INFO] Detecting installed PHP versions..."

    PHP_VERSIONS=$(find /etc/php/ -maxdepth 1 -mindepth 1 -type d 2>/dev/null | xargs -n1 basename 2>/dev/null | sort -V)

    echo ""
    echo "Detected PHP:"
    echo "$PHP_VERSIONS"

    # ============================================================
    # FILTER VERSI PHP (jika dipilih)
    # ============================================================

    if [[ -n "$PHP_SELECT" ]]; then
        local FILTERED=""
        local PV
        for PV in ${PHP_SELECT//,/ }; do
            if grep -qx "$PV" <<<"$PHP_VERSIONS"; then
                FILTERED="${FILTERED}
${PV}"
            else
                echo -e "${YELLOW}Warning: PHP $PV tidak terdeteksi, dilewati.${NC}"
            fi
        done
        PHP_VERSIONS="$(printf '%s\n' "$FILTERED" | sed '/^$/d')"
        echo ""
        echo "PHP yang akan ditune:"
        echo "$PHP_VERSIONS"
    fi

    # ============================================================
    # AUTO CALCULATION
    # ============================================================

    if (( RAM <= 2 )); then
        BUFFER_POOL=1
        BP_VALUE="512M"
    elif (( RAM <= 4 )); then
        BUFFER_POOL=1
        BP_VALUE="1G"
    else
        BUFFER_POOL=$((RAM * 25 / 100))
        [ $BUFFER_POOL -lt 1 ] && BUFFER_POOL=1
        [ $BUFFER_POOL -gt 8 ] && BUFFER_POOL=8
        BP_VALUE="${BUFFER_POOL}G"
    fi

    BP_INST=$((BUFFER_POOL / 2))

    [ $BP_INST -lt 1 ] && BP_INST=1
    [ $BP_INST -gt 8 ] && BP_INST=8

    LOG_FILE_MB=$((BUFFER_POOL * 128))

    [ $LOG_FILE_MB -lt 256 ] && LOG_FILE_MB=256
    [ $LOG_FILE_MB -gt 1024 ] && LOG_FILE_MB=1024

    REDO_MB=$((LOG_FILE_MB * 2))

    MAX_CONN=$((CORE * 8))

    [ $MAX_CONN -lt 100 ] && MAX_CONN=100
    [ $MAX_CONN -gt 200 ] && MAX_CONN=200

    THREAD_CACHE=$((MAX_CONN / 2))

    # ============================================================
    # PRE-FLIGHT CHECK (SEBELUM MENGUBAH APAPUN)
    # ============================================================

    echo ""
    echo "[INFO] Pre-flight check..."

    MYSQL_NOW="$(systemctl is-active mysql 2>/dev/null)"
    if [[ "$MYSQL_NOW" != "active" ]]; then
        echo -e "${RED}[ERROR] MySQL sedang TIDAK aktif ($MYSQL_NOW). Tune up dibatalkan.${NC}"
        echo "Periksa dulu kenapa MySQL mati: journalctl -u mysql --no-pager -n 30"
        return 1
    fi

    FAILED_UNITS="$(systemctl --state=failed --no-legend --no-pager --plain 2>/dev/null | awk '{print $1}' | tr '\n' ' ')"

    CRIT_FAILED=""
    for U in ${FAILED_UNITS}; do
        case "$U" in
            *.mount) CRIT_FAILED="${CRIT_FAILED} ${U}" ;;
        esac
    done

    if [[ -n "${CRIT_FAILED//[[:space:]]/}" ]]; then
        echo -e "${RED}[ERROR] Ada mount yang gagal: ${CRIT_FAILED}${NC}"
        echo "Tune up dibatalkan: MySQL tidak akan bisa start selama mount tersebut gagal."
        echo "Cek: systemctl --state=failed"
        echo "Jika *.mount gagal (mis. boot.mount), perbaiki /etc/fstab:"
        echo "  ganti 'LABEL=...' dengan 'UUID=...' (lihat blkid), lalu systemctl reset-failed"
        cp ${MYSQL_CONF}.backup.$DATE $MYSQL_CONF
        return 1
    fi

    echo -e "${GREEN}Pre-flight OK (MySQL aktif, tidak ada unit failed).${NC}"

    # ============================================================
    # BACKUP MYSQL CONFIG
    # ============================================================

    echo ""
    echo "[INFO] Backup MySQL config..."

    cp $MYSQL_CONF ${MYSQL_CONF}.backup.$DATE 2>/dev/null

    # ============================================================
    # WRITE MYSQL CONFIG
    # ============================================================

    echo ""
    echo "[INFO] Writing MySQL config..."

    cat > $MYSQL_CONF <<EOF
[mysqld]

bind-address = 0.0.0.0
port = 3306

pid-file = /var/run/mysqld/mysqld.pid
socket = /var/run/mysqld/mysqld.sock

datadir = /home/mysql/

log-error = /var/log/mysql/error.log

mysql-native-password = ON

skip-name-resolve

innodb_file_per_table = ON

sql_mode = STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION

character_set_server = utf8mb4
collation_server = utf8mb4_general_ci

# ============================================================
# CONNECTION
# ============================================================

max_connections = ${MAX_CONN}
thread_cache_size = ${THREAD_CACHE}

table_open_cache = 2000
table_definition_cache = 2000

open_files_limit = 50000

# ============================================================
# MEMORY SAFE
# ============================================================

sort_buffer_size = 512K
join_buffer_size = 512K

read_buffer_size = 512K
read_rnd_buffer_size = 512K

tmp_table_size = 32M
max_heap_table_size = 32M

bulk_insert_buffer_size = 16M

max_allowed_packet = 64M

# ============================================================
# INNODB SAFE
# ============================================================

innodb_buffer_pool_size = ${BP_VALUE}
innodb_buffer_pool_instances = ${BP_INST}

innodb_redo_log_capacity = ${REDO_MB}M

innodb_log_buffer_size = 32M

innodb_flush_log_at_trx_commit = 2

innodb_flush_method = O_DIRECT

innodb_io_capacity = 800
innodb_io_capacity_max = 1200

innodb_read_io_threads = 2
innodb_write_io_threads = 2

# ============================================================
# SAFE MODE
# ============================================================

performance_schema = OFF

# ============================================================
# TIMEOUT
# ============================================================

wait_timeout = 60
interactive_timeout = 60

# ============================================================
# LOGGING
# ============================================================

slow_query_log = 1
slow_query_log_file = /var/log/mysql/slow.log

long_query_time = 2

# ============================================================
# CLIENT SOCKET
# ============================================================

[client]
socket = /var/run/mysqld/mysqld.sock

[mysql]
socket = /var/run/mysqld/mysqld.sock

EOF

    # ============================================================
    # FIX MYSQL SOCKET
    # ============================================================

    echo ""
    echo "[INFO] Fixing MySQL socket..."

    mkdir -p /var/run/mysqld
    mkdir -p /var/lib/mysql

    chown mysql:mysql /var/run/mysqld /var/lib/mysql
    chmod 755 /var/run/mysqld /var/lib/mysql

    ln -sf /var/run/mysqld/mysqld.sock /tmp/mysql.sock 2>/dev/null || true
    ln -sf /var/run/mysqld/mysqld.sock /var/lib/mysql/mysql.sock 2>/dev/null || true

    # ============================================================
    # CEK DATADIR AKTIF (SAFETY)
    # ============================================================

    CURRENT_DATA="$(mysql -N -e "SELECT @@datadir" 2>/dev/null | tail -1)"

    if [[ -n "$CURRENT_DATA" ]] && [[ "${CURRENT_DATA%/}" != "${MYSQL_DATA%/}" ]]; then
        echo -e "${RED}[ERROR] Datadir aktif ($CURRENT_DATA) beda dari $MYSQL_DATA. Batal.${NC}"
        cp ${MYSQL_CONF}.backup.$DATE $MYSQL_CONF
        return 1
    fi

    if [[ ! -f "${MYSQL_DATA}/ibdata1" ]]; then
        echo -e "${RED}[ERROR] Datadir $MYSQL_DATA tidak valid (ibdata1 tidak ada). Batal.${NC}"
        cp ${MYSQL_CONF}.backup.$DATE $MYSQL_CONF
        return 1
    fi

    # ============================================================
    # STOP MYSQL
    # ============================================================

    echo ""
    echo "[INFO] Stopping MySQL..."

    systemctl stop mysql

    sleep 3

    # ============================================================
    # CLEAN REDO LOG (hanya untuk MySQL < 8, redo 8.x otomatis)
    # ============================================================

    MYSQL_VERSION="$(mysqld --version 2>/dev/null | sed -n 's/.*Ver \([0-9]*\)\.[0-9]*\.[0-9]*.*/\1/p')"

    if [[ "$MYSQL_VERSION" =~ ^[0-9]+$ ]] && (( MYSQL_VERSION >= 8 )); then
        echo ""
        echo "[INFO] MySQL $MYSQL_VERSION: redo log dikelola otomatis (innodb_redo_log_capacity). Skip cleanup redo."
    else
        echo ""
        echo "[INFO] Cleaning old redo log (MySQL ${MYSQL_VERSION:-?})..."
        rm -f ${MYSQL_DATA}/ib_logfile* 2>/dev/null
        rm -rf ${MYSQL_DATA}/#ib_redo/* 2>/dev/null
        rm -rf ${MYSQL_DATA}/#innodb_redo/* 2>/dev/null
    fi

    # ============================================================
    # TEST MYSQL CONFIG
    # ============================================================

    echo ""
    echo "[INFO] Testing MySQL config..."

    mysqld --validate-config

    if [ $? -ne 0 ]; then
        echo ""
        echo -e "${RED}[ERROR] MYSQL CONFIG INVALID!${NC}"

        cp ${MYSQL_CONF}.backup.$DATE $MYSQL_CONF

        return 1
    fi

    # ============================================================
    # START MYSQL
    # ============================================================

    echo ""
    echo "[INFO] Starting MySQL..."

    systemctl start mysql

    sleep 5

    MYSQL_STATUS=$(systemctl is-active mysql)

    if [ "$MYSQL_STATUS" != "active" ]; then
        echo ""
        echo -e "${RED}[ERROR] MYSQL FAILED START!${NC}"

        echo "--- systemctl list-dependencies mysql.service ---"
        systemctl list-dependencies mysql.service --no-pager | tail -20

        echo "--- journalctl mysql.service (last 60) ---"
        journalctl -u mysql --no-pager -n 60

        echo "--- /var/log/mysql/error.log (last 40) ---"
        tail -40 /var/log/mysql/error.log 2>/dev/null

        echo "--- restore backup config ---"
        cp ${MYSQL_CONF}.backup.$DATE $MYSQL_CONF

        systemctl restart mysql
        sleep 3

        echo -e "Status MySQL setelah restore: ${GREEN}$(systemctl is-active mysql)${NC}"

        echo ""
        echo -e "${YELLOW}TIP: Kalau MySQL tetap gagal start, kemungkinan ada unit systemd yang failed${NC}"
        echo "  systemctl --state=failed"
        echo "  systemctl reset-failed"
        echo "Jika ada *.mount (mis. boot.mount) yang gagal, perbaiki /etc/fstab:"
        echo "  ganti 'LABEL=...' dengan 'UUID=...' (lihat blkid)"
        echo "  systemctl daemon-reload && mount -a"

        return 1
    fi

    # ============================================================
    # FIX ALL PHP
    # ============================================================

    for PHPVER in $PHP_VERSIONS
    do

    PHP_INI="/etc/php/${PHPVER}/fpm/php.ini"
    POOL_DIR="/etc/php/${PHPVER}/fpm/pool.d"

    if [ ! -f "$PHP_INI" ]; then
        continue
    fi

    echo ""
    echo "================================================="
    echo " FIXING PHP ${PHPVER}"
    echo "================================================="

    cp $PHP_INI ${PHP_INI}.backup.$DATE 2>/dev/null

    # ============================================================
    # CLEAN BROKEN PHP.INI
    # ============================================================

    echo ""
    echo "[INFO] Cleaning broken php.ini ${PHPVER}..."

    sed -i '/imagick.somysqli.default_socket/d' $PHP_INI
    sed -i '/unexpected token/d' $PHP_INI

    sed -i '/^[[:space:]]*and[[:space:]]*$/d' $PHP_INI
    sed -i '/^[[:space:]]*or[[:space:]]*$/d' $PHP_INI

    sed -i '/^[[:space:]]*=[[:space:]]*$/d' $PHP_INI

    sed -i '/mysqli.default_socket/d' $PHP_INI
    sed -i '/pdo_mysql.default_socket/d' $PHP_INI

    sed -i '/extension *= *imagick.so/d' $PHP_INI

    sed -i 's/\r//g' $PHP_INI

    # ============================================================
    # ADD SAFE CONFIG
    # ============================================================

    echo ""
    echo "[INFO] Writing safe config PHP ${PHPVER}..."

    cat >> $PHP_INI <<EOF

; ============================================================
; SMART SAFE TUNER
; ============================================================

extension=imagick.so

mysqli.default_socket = /var/run/mysqld/mysqld.sock
pdo_mysql.default_socket = /var/run/mysqld/mysqld.sock

memory_limit = 256M
max_execution_time = 60
max_input_time = 60

post_max_size = 64M
upload_max_filesize = 64M

max_input_vars = 3000

date.timezone = Asia/Jakarta

cgi.fix_pathinfo = 0

opcache.enable=1
opcache.memory_consumption=128
opcache.interned_strings_buffer=16
opcache.max_accelerated_files=10000
opcache.validate_timestamps=1
opcache.revalidate_freq=2

EOF

    # ============================================================
    # FIX POOL CONFIG
    # ============================================================

    echo ""
    echo "[INFO] Fixing pool config PHP ${PHPVER}..."

    rm -f ${POOL_DIR}/99-global.conf 2>/dev/null

    for pool in ${POOL_DIR}/*.conf
    do

        [ ! -f "$pool" ] && continue

        BASENAME=$(basename "$pool")

        if [[ "$BASENAME" == "global.conf" ]]; then
            continue
        fi

        echo "[FIX] $BASENAME"

        sed -i 's/yespm./yes\npm./g' $pool
        sed -i 's/0pm./0\npm./g' $pool
        sed -i 's/yespm.max/yes\npm.max/g' $pool

        sed -i '/pm.start_servers/d' $pool
        sed -i '/pm.min_spare_servers/d' $pool
        sed -i '/pm.max_spare_servers/d' $pool

        sed -i '/catch_workers_output/d' $pool
        echo "catch_workers_output = yes" >> $pool

        if grep -q "^pm =" $pool; then
            sed -i 's/^pm =.*/pm = dynamic/g' $pool
        else
            echo "pm = dynamic" >> $pool
        fi

        if grep -q "^pm.max_children" $pool; then
            sed -i 's/^pm.max_children.*/pm.max_children = 10/g' $pool
        else
            echo "pm.max_children = 10" >> $pool
        fi

        if grep -q "^pm.max_requests" $pool; then
            sed -i 's/^pm.max_requests.*/pm.max_requests = 300/g' $pool
        else
            echo "pm.max_requests = 300" >> $pool
        fi

        echo "pm.start_servers = 2" >> $pool
        echo "pm.min_spare_servers = 2" >> $pool
        echo "pm.max_spare_servers = 4" >> $pool

    done

    # ============================================================
    # TEST PHP.INI
    # ============================================================

    echo ""
    echo "[INFO] Testing PHP.INI ${PHPVER}..."

    php -n -l $PHP_INI

    # ============================================================
    # TEST PHP-FPM
    # ============================================================

    echo ""
    echo "[INFO] Testing PHP-FPM ${PHPVER}..."

    if command -v php-fpm${PHPVER} >/dev/null 2>&1; then
        php-fpm${PHPVER} -t
    fi

    systemctl restart php${PHPVER}-fpm 2>/dev/null

    done

    # ============================================================
    # RESTART NGINX
    # ============================================================

    echo ""
    echo "[INFO] Restarting nginx..."

    nginx -t

    if [ $? -eq 0 ]; then
        systemctl restart nginx
    fi

    # ============================================================
    # RESOURCE MONITOR
    # ============================================================

    echo ""
    echo "================================================="
    echo " RESOURCE MONITOR"
    echo "================================================="

    echo ""
    echo "[TOP CPU]"
    ps -eo pid,cmd,%mem,%cpu --sort=-%cpu | head -15

    echo ""
    echo "[TOP MEMORY]"
    ps -eo pid,cmd,%mem,%cpu --sort=-%mem | head -15

    echo ""
    echo "[DISK]"
    df -h

    echo ""
    echo "[MYSQL]"
    ps aux | grep mysqld | grep -v grep

    echo ""
    echo "[PHP-FPM]"
    ps aux | grep php-fpm | grep -v grep | head

    echo ""
    echo "[OOM LOG]"
    dmesg -T | grep -i oom | tail -10

    # ============================================================
    # AI RECOMMENDATION
    # ============================================================

    echo ""
    echo "================================================="
    echo " SMART AI RECOMMENDATION"
    echo "================================================="

    USED_RAM=$(free | awk '/Mem:/ {print int($3/$2 * 100)}')
    USED_DISK=$(df / | awk 'END{print int($5)}')

    echo ""
    echo "RAM Usage  : ${USED_RAM}%"
    echo "Disk Usage : ${USED_DISK}%"

    echo ""

    if [ $USED_RAM -ge 90 ]; then
        echo "[CRITICAL] RAM hampir habis"
        echo "- Upgrade RAM"
        echo "- Turunkan pm.max_children"
        echo "- Turunkan max_connections"
    elif [ $USED_RAM -ge 75 ]; then
        echo "[WARNING] RAM cukup tinggi"
        echo "- Optimasi query"
        echo "- Aktifkan Redis"
    else
        echo "[GOOD] RAM masih aman"
    fi

    echo ""

    if [ $USED_DISK -ge 90 ]; then
        echo "[CRITICAL] Disk hampir penuh"
        echo "- Bersihkan log"
        echo "- Hapus backup lama"
    elif [ $USED_DISK -ge 75 ]; then
        echo "[WARNING] Disk usage tinggi"
        echo "- Bersihkan cache"
    else
        echo "[GOOD] Storage masih aman"
    fi

    echo ""

    LOAD=$(uptime | awk -F'load average:' '{ print $2 }' | cut -d, -f1 | sed 's/ //g')
    LOAD_INT=${LOAD%.*}

    echo "CPU Load : $LOAD"

    echo ""

    if [ "$LOAD_INT" -ge "$CORE" ]; then
        echo "[WARNING] CPU bottleneck"
        echo "- Upgrade CPU"
        echo "- Optimasi cronjob"
    else
        echo "[GOOD] CPU aman"
    fi

    # ============================================================
    # FINAL STATUS
    # ============================================================

    echo ""
    echo "================================================="
    echo " FINAL STATUS"
    echo "================================================="

    systemctl --type=service | grep -E "mysql|php.*fpm|nginx"

    echo ""
    echo "================================================="
    echo " SMART SAFE TUNER SUCCESS"
    echo "================================================="

    echo "RAM VPS         : ${RAM} GB"
    echo "CPU CORE        : ${CORE}"
    echo "Buffer Pool     : ${BUFFER_POOL} GB"
    echo "BP Instances    : ${BP_INST}"
    echo "Redo Log        : ${LOG_FILE_MB} MB"
    echo "Max Connections : ${MAX_CONN}"

    echo ""
    echo "MYSQL STATUS:"
    systemctl is-active mysql

    echo ""
    echo "NGINX STATUS:"
    systemctl is-active nginx

    echo ""
    echo "MYSQL SOCKET:"
    echo "/var/run/mysqld/mysqld.sock"

    echo ""
    echo "================================================="
    echo " CLOUDPANEL SAFE"
    echo " MULTI PHP SAFE"
    echo " CODEIGNITER SAFE"
    echo " MYSQL NATIVE PASSWORD = ON"
    echo " IMAGICK SAFE"
    echo " SOCKET SAFE"
    echo " AUTO RECOVERY ENABLED"
    echo "================================================="

    echo ""
    echo "SET .ENV:"
    echo "database.default.hostname = localhost"

    echo ""

    return 0
}


# =====================================================
# MENU CLEAN CACHE
# =====================================================

menu_clean() {
    clear
    echo "=============================================================="
    echo "  CLEAN CACHE (SERVER + CI4)"
    echo "=============================================================="
    echo
    echo -e "${YELLOW}CI4: hapus cache/logs/debugbar + session lama (>120 mnt)${NC}"
    echo -e "${YELLOW}     Session yang sedang aktif TIDAK diganggu.${NC}"
    echo

    read -r -p "Jalankan clean cache server? (y/n): " SERVER
    if [[ "$SERVER" =~ ^[Yy]$ ]]; then
        clean_server_cache
    fi

    echo
    read -r -p "Jalankan clean cache CI4 (writable)? (y/n): " CI4
    if [[ "$CI4" =~ ^[Yy]$ ]]; then
        read -r -p "Batas aman session (menit, default 120): " SAFE_MINUTES
        [[ ! "$SAFE_MINUTES" =~ ^[0-9]+$ ]] || (( SAFE_MINUTES < 1 )) && SAFE_MINUTES=120

        echo
        read -r -p "Pilih domain? (y/n, n = semua): " SEL
        if [[ "$SEL" =~ ^[Yy]$ ]]; then
            if select_domains; then
                for CHOICE in "${SELECTED[@]}"; do
                    clean_ci4_domain "${DOMAINS[$((CHOICE - 1))]}" "$SAFE_MINUTES"
                done
            fi
        else
            for DOMAIN in "${DOMAINS[@]}"; do
                clean_ci4_domain "$DOMAIN" "$SAFE_MINUTES"
            done
        fi
    fi

    echo
    read -r -p "Tekan ENTER..."
}


# =====================================================
# FUNGSI CLEAN CACHE SERVER
# =====================================================

clean_server_cache() {
    echo ""
    echo "=============================================================="
    echo "  CLEAN SERVER CACHE"
    echo "=============================================================="

    echo -e "${YELLOW}Vacuum journal log (maks 100M)...${NC}"
    journalctl --vacuum-size=100M >/dev/null 2>&1

    echo -e "${YELLOW}Clean apt cache...${NC}"
    apt-get clean >/dev/null 2>&1

    echo -e "${YELLOW}Clean /tmp (file lebih dari 1 hari)...${NC}"
    find /tmp -type f -mtime +1 -delete 2>/dev/null

    echo -e "${YELLOW}Clean nginx cache...${NC}"
    find /var/cache/nginx -type f -delete 2>/dev/null

    echo -e "${YELLOW}Clean nginx log lama (rotate >7 hari)...${NC}"
    find /var/log/nginx -type f -name "*.log.*" -mtime +7 -delete 2>/dev/null

    echo ""
    read -r -p "Bersihkan RAM cache (drop_caches)? (y/n): " DROP
    if [[ "$DROP" =~ ^[Yy]$ ]]; then
        sync
        echo 3 > /proc/sys/vm/drop_caches
        echo -e "${GREEN}RAM cache dibersihkan.${NC}"
    fi

    echo ""
    read -r -p "Restart semua PHP-FPM (bersihkan opcache)? (y/n): " FPM
    if [[ "$FPM" =~ ^[Yy]$ ]]; then
        for PHPVER in $(find /etc/php/ -maxdepth 1 -mindepth 1 -type d 2>/dev/null | xargs -n1 basename 2>/dev/null); do
            systemctl restart "php${PHPVER}-fpm" 2>/dev/null
        done
        echo -e "${GREEN}PHP-FPM di-restart, opcache dibersihkan.${NC}"
    fi

    echo -e "${GREEN}Server cache selesai dibersihkan.${NC}"
}


# =====================================================
# FUNGSI CLEAN CI4 WRITABLE
# =====================================================

clean_ci4_domain() {
    local DOMAIN="$1"
    local SAFE_MINUTES="${2:-120}"
    local SITE_USER DEST_ROOT WRITABLE BEFORE AFTER FREED OLD_COUNT

    SITE_USER="$(make_site_user "$DOMAIN" 2>/dev/null)" || return 1
    DEST_ROOT="/home/${SITE_USER}/htdocs/${DOMAIN}"
    WRITABLE="${DEST_ROOT}/writable"

    if ! id "$SITE_USER" >/dev/null 2>&1; then
        echo -e "${RED}  SKIP: $DOMAIN (site user tidak ada)${NC}"
        return 1
    fi

    if [[ ! -d "$WRITABLE" ]]; then
        echo -e "${YELLOW}  SKIP: $DOMAIN (writable tidak ada)${NC}"
        return 0
    fi

    BEFORE="$(du -sb "$WRITABLE" 2>/dev/null | cut -f1)"

    echo ""
    echo -e "  ${CYAN}CLEAN CI4: $DOMAIN${NC}"

    if [[ -d "$WRITABLE/cache" ]]; then
        find "$WRITABLE/cache" -mindepth 1 -delete 2>/dev/null
        echo -e "    ${GREEN}cache   : bersih${NC}"
    fi

    if [[ -d "$WRITABLE/debugbar" ]]; then
        find "$WRITABLE/debugbar" -mindepth 1 -delete 2>/dev/null
        echo -e "    ${GREEN}debugbar: bersih${NC}"
    fi

    if [[ -d "$WRITABLE/logs" ]]; then
        find "$WRITABLE/logs" -type f \( -name "*.log" -o -name "*.json" \) -delete 2>/dev/null
        echo -e "    ${GREEN}logs    : bersih${NC}"
    fi

    if [[ -d "$WRITABLE/session" ]]; then
        OLD_COUNT="$(find "$WRITABLE/session" -type f -mmin +"$SAFE_MINUTES" 2>/dev/null | wc -l)"
        find "$WRITABLE/session" -type f -mmin +"$SAFE_MINUTES" -delete 2>/dev/null
        echo -e "    ${YELLOW}session : hapus $OLD_COUNT file lama (> ${SAFE_MINUTES} mnt aktif)${NC}"
    fi

    chown -R "$SITE_USER:$SITE_USER" "$WRITABLE"
    chmod -R 775 "$WRITABLE"

    AFTER="$(du -sb "$WRITABLE" 2>/dev/null | cut -f1)"
    FREED=$(( (BEFORE - AFTER) / 1024 ))
    [[ "$FREED" -lt 0 ]] && FREED=0

    echo -e "    ${GREEN}Hemat: ~${FREED} KB${NC}"
    return 0
}


# =====================================================
# MENU MIGRATE MASTER
# =====================================================

menu_migrate() {
    clear
    echo "=============================================================="
    echo "  MIGRATE DATABASE (CI4 spark migrate)"
    echo "=============================================================="
    echo
    echo "Source: $SOURCE_DOMAIN ($SOURCE_USER)"
    echo

    local SRC_ROOT="/home/${SOURCE_USER}/htdocs/${SOURCE_DOMAIN}"

    if [[ ! -d "$SRC_ROOT" ]]; then
        echo -e "${RED}ERROR: Source tidak ditemukan: $SRC_ROOT${NC}"
        read -r -p "Tekan ENTER..."
        return 1
    fi

    echo "Menjalankan: php spark migrate"
    echo

    if (
        cd "$SRC_ROOT" && php spark migrate
    ); then
        echo
        echo -e "${GREEN}Migrate selesai.${NC}"
    else
        echo
        echo -e "${RED}Migrate gagal / ada error. Periksa output di atas.${NC}"
    fi

    echo
    read -r -p "Tekan ENTER..."
}


# =====================================================
# MENU CEK STATUS TUNE UP
# =====================================================

menu_tune_status() {
    clear
    echo "=============================================================="
    echo "  STATUS TUNE UP SERVER"
    echo "=============================================================="

    local MYSQL_CONF="/etc/mysql/mysql.conf.d/mysqld.cnf"
    local RAM_GB CORE BP_VALUE MYSQL_TUNED PHP_TUNED PHPVER LAST_BK

    RAM_GB="$(free -g | awk '/^Mem:/{print $2}')"
    [[ ! "$RAM_GB" =~ ^[0-9]+$ ]] && RAM_GB=0
    CORE="$(nproc 2>/dev/null)"

    echo ""
    echo "RAM saat ini : ${RAM_GB} GB"
    echo "CPU Core     : $CORE"
    echo "MySQL status : $(systemctl is-active mysql 2>/dev/null)"
    echo ""

    MYSQL_TUNED="NO"
    if [[ -f "$MYSQL_CONF" ]] && grep -qE "mysql-native-password|innodb_redo_log_capacity" "$MYSQL_CONF" 2>/dev/null; then
        MYSQL_TUNED="YES"
    fi

    echo "--- MySQL ---"
    if [[ "$MYSQL_TUNED" == "YES" ]]; then
        echo -e "  Sudah di-tune : ${GREEN}YA${NC}"
        BP_VALUE="$(sed -n 's/^innodb_buffer_pool_size[[:space:]]*=[[:space:]]*//p' "$MYSQL_CONF" 2>/dev/null)"
        echo "  Buffer pool   : ${BP_VALUE:-?}"

        if [[ -n "$BP_VALUE" ]]; then
            local BP_NUM=0
            case "$BP_VALUE" in
                *G) BP_NUM="${BP_VALUE%G}" ;;
                *M) BP_NUM="$(( ${BP_VALUE%M} / 1024 ))" ;;
            esac
            if (( RAM_GB > 0 )) && (( BP_NUM > RAM_GB / 2 )); then
                echo -e "  ${RED}WARNING: buffer pool ${BP_VALUE} terlalu besar untuk RAM ${RAM_GB}GB (>=50%, risiko OOM). Jalankan Tune Up.${NC}"
            elif (( RAM_GB > 0 )) && (( BP_NUM > 0 )) && (( BP_NUM < RAM_GB / 8 )); then
                echo -e "  ${YELLOW}Catatan: buffer pool ${BP_VALUE} tergolong kecil untuk RAM ${RAM_GB}GB (lebih cocok RAM rendah).${NC}"
            fi
        fi

        LAST_BK="$(ls -t "${MYSQL_CONF}.backup."* 2>/dev/null | head -1)"
        if [[ -n "$LAST_BK" ]]; then
            echo "  Backup cfg    : $(stat -c '%y' "$LAST_BK" 2>/dev/null | cut -d. -f1)"
        fi
    else
        echo -e "  Sudah di-tune : ${RED}BELUM${NC} (config MySQL default / belum ditune)"
    fi

    echo ""
    echo "--- PHP-FPM ---"
    PHP_TUNED="NO"
    for PHPVER in $(find /etc/php/ -maxdepth 1 -mindepth 1 -type d 2>/dev/null | xargs -n1 basename 2>/dev/null | sort -V); do
        local INI="/etc/php/${PHPVER}/fpm/php.ini"
        if [[ -f "$INI" ]] && grep -q "SMART SAFE TUNER" "$INI" 2>/dev/null; then
            echo -e "  PHP ${PHPVER} : ${GREEN}tuned${NC}"
            PHP_TUNED="YES"
        else
            echo -e "  PHP ${PHPVER} : ${RED}belum${NC}"
        fi
    done

    echo ""
    echo "Kesimpulan:"
    if [[ "$MYSQL_TUNED" == "YES" ]] && [[ "$PHP_TUNED" == "YES" ]]; then
        echo -e "  ${GREEN}Server sudah di-tune up (MySQL + PHP).${NC}"
    elif [[ "$MYSQL_TUNED" == "YES" ]] || [[ "$PHP_TUNED" == "YES" ]]; then
        echo -e "  ${YELLOW}Sebagian sudah di-tune (parsial).${NC}"
    else
        echo -e "  ${RED}Belum di-tune up. Jalankan menu Tune Up (no. 8).${NC}"
    fi

    echo
    read -r -p "Tekan ENTER..."
}


# =====================================================
# FUNGSI UPDATE .ENV CUSTOM PER DOMAIN
# =====================================================

update_env_domain() {
    local DOMAIN="$1"
    local SITE_USER DEST_ROOT ENV_FILE SUBDOMAIN

    SITE_USER="$(make_site_user "$DOMAIN" 2>/dev/null)" || return 1
    DEST_ROOT="/home/${SITE_USER}/htdocs/${DOMAIN}"
    ENV_FILE="${DEST_ROOT}/.env"

    if ! id "$SITE_USER" >/dev/null 2>&1; then
        echo -e "${RED}  SKIP: $DOMAIN (site user tidak ada)${NC}"
        return 1
    fi

    if [[ ! -f "$ENV_FILE" ]]; then
        echo -e "${RED}  SKIP: $DOMAIN (.env tidak ada)${NC}"
        return 1
    fi

    SUBDOMAIN="${DOMAIN%%.*}"
    SUBDOMAIN="${SUBDOMAIN,,}"

    set_env_value "$ENV_FILE" "database.default.database" "u${SUBDOMAIN}"
    set_env_value "$ENV_FILE" "database.default.username" "d${SUBDOMAIN}"
    set_env_value "$ENV_FILE" "database.default.password" "${SUBDOMAIN}@1234"

    echo -e "${GREEN}  OK: $DOMAIN -> u${SUBDOMAIN} / d${SUBDOMAIN} / ${SUBDOMAIN}@1234${NC}"
    return 0
}


# =====================================================
# MENU UPDATE .ENV CUSTOM
# =====================================================

menu_update_env() {
    clear
    echo "=============================================================="
    echo "  UPDATE .ENV CUSTOM (Database Credential)"
    echo "=============================================================="
    echo
    echo "Master aktif: $SOURCE_DOMAIN"
    echo
    echo "Langkah:"
    echo "  1. Merge .env dari master (tambah key baru yang belum ada)"
    echo "  2. Set credential database custom per domain"
    echo

    if [[ "$DB_PATTERN" == "u" ]]; then
        echo "Credential pattern (u<sub>/d<sub>):"
        echo "  database.default.database = u<subdomain>"
        echo "  database.default.username = d<subdomain>"
        echo "  database.default.password = <subdomain>@1234"
        echo
        echo "Contoh: tanggamus2 -> utanggamus2 / dtanggamus2 / tanggamus2@1234"
    else
        echo "Credential pattern (us<sub>/ds<sub>):"
        echo "  database.default.database = us<subdomain>"
        echo "  database.default.username = ds<subdomain>"
        echo "  database.default.password = <subdomain>@1234"
        echo
        echo "Contoh: tanggamus2 -> ustanggamus2 / dstanggamus2 / tanggamus2@1234"
    fi
    echo

    if ! select_domains; then
        read -r -p "Tekan ENTER..."; return
    fi

    echo
    read -r -p "Update .env untuk ${#SELECTED[@]} domain terpilih? (y/n): " CONFIRM
    [[ ! "$CONFIRM" =~ ^[Yy]$ ]] && { echo "Dibatalkan."; return; }

    local SRC_ENV="/home/${SOURCE_USER}/htdocs/${SOURCE_DOMAIN}/.env"
    local OK=0 FAIL=0

    echo
    for CHOICE in "${SELECTED[@]}"; do
        local DOM="${DOMAINS[$((CHOICE - 1))]}"
        local SU DEST_ROOT ENV_FILE SUBDOMAIN

        SU="$(make_site_user "$DOM" 2>/dev/null)" || { FAIL=$((FAIL + 1)); continue; }
        DEST_ROOT="/home/${SU}/htdocs/${DOM}"
        ENV_FILE="${DEST_ROOT}/.env"

        if ! id "$SU" >/dev/null 2>&1; then
            echo -e "${RED}  SKIP: $DOM (site user tidak ada)${NC}"
            FAIL=$((FAIL + 1))
            continue
        fi

        if [[ ! -f "$ENV_FILE" ]]; then
            echo -e "${RED}  SKIP: $DOM (.env tidak ada)${NC}"
            FAIL=$((FAIL + 1))
            continue
        fi

        SUBDOMAIN="${DOM%%.*}"
        SUBDOMAIN="${SUBDOMAIN,,}"

        echo -e "${CYAN}  $DOM${NC}"

        # Step 1: Merge dari master
        echo -ne "    Merge dari master... "
        if merge_env_missing "$SRC_ENV" "$ENV_FILE"; then
            echo -e "${GREEN}OK${NC}"
        else
            echo -e "${YELLOW}skip${NC}"
        fi

        # Step 2: Set custom credential (beda per master)
        echo -ne "    Set credential... "
        if [[ "$DB_PATTERN" == "u" ]]; then
            # Pattern u<sub> / d<sub>
            set_env_value "$ENV_FILE" "database.default.database" "u${SUBDOMAIN}"
            set_env_value "$ENV_FILE" "database.default.username" "d${SUBDOMAIN}"
            set_env_value "$ENV_FILE" "database.default.password" "${SUBDOMAIN}@1234"
            echo -e "${GREEN}OK (u${SUBDOMAIN} / d${SUBDOMAIN} / ${SUBDOMAIN}@1234)${NC}"
        else
            # Pattern us<sub> / ds<sub>
            set_env_value "$ENV_FILE" "database.default.database" "us${SUBDOMAIN}"
            set_env_value "$ENV_FILE" "database.default.username" "ds${SUBDOMAIN}"
            set_env_value "$ENV_FILE" "database.default.password" "${SUBDOMAIN}@1234"
            echo -e "${GREEN}OK (us${SUBDOMAIN} / ds${SUBDOMAIN} / ${SUBDOMAIN}@1234)${NC}"
        fi

        # Step 3: Set result_sync
        echo -ne "    Set result_sync... "
        set_env_value "$ENV_FILE" "result_sync.main_server_url" "https://${SOURCE_DOMAIN}"
        set_env_value "$ENV_FILE" "result_sync.enabled" "true"
        set_env_value "$ENV_FILE" "result_sync.api_key" "a386b6b2faf942a71ed16bac66ad53f43eb27a6740862e16c63ca2d6b074f774"
        set_env_value "$ENV_FILE" "dsmart.syncBaseUrl" "https://dsmartlampung.com/api"
        set_env_value "$ENV_FILE" "dsmart.syncApiKey" "a386b6b2faf942a71ed16bac66ad53f43eb27a6740862e16c63ca2d6b074f774"
        echo -e "${GREEN}OK${NC}"

        # Step 4: Set DSMART_KARAKTER_URL
        echo -ne "    Set DSMART_KARAKTER_URL... "
        set_env_value "$ENV_FILE" "DSMART_KARAKTER_URL" "https://karakter.dsmartlampung.com/"
        echo -e "${GREEN}OK${NC}"

        # Step 5: Set keys khusus dsmart
        if [[ "$SOURCE_DOMAIN" == "dsmartlampung.com" ]]; then
            echo -ne "    Set dsmart keys... "
            set_env_value "$ENV_FILE" "MBTI_SYNC_API_KEY" "a386b6b2faf942a71ed16bac66ad53f43eb27a6740862e16c63ca2d6b074f774"
            set_env_value "$ENV_FILE" "FCM_API_KEY" "AAAAJxm6MGM:APA91bFd2G-75dfzfaqHA3rVxeUO5iR34VnvBDwve28xBy7xGBekxRxZOoHLzQ7Y-SsiMvr6KdsSZSdAf0QBKQyhfmtOhOSlmMMvBKhtcxhLE_3aE5Vr6NpQGsT5ARdEZltEs0-RJBac"
            set_env_value "$ENV_FILE" "AI_DRIVER" "ollama"
            set_env_value "$ENV_FILE" "GEMINI_API_KEY" "AIzaSyBTui45oeGvVj4z7OrcsWKb1e7XldQV3kg"
            set_env_value "$ENV_FILE" "OLLAMA_API_KEY" "a43c91bbe05547a58e26511081381855.o7iTA-eCL9ru5xjFWv4j-Wdg"
            set_env_value "$ENV_FILE" "OLLAMA_API_URL" "https://ollama.com/api/generate"
            set_env_value "$ENV_FILE" "OLLAMA_MODEL" "gemini-3-flash-preview"
            set_env_value "$ENV_FILE" "CI_ENVIRONMENT" "production"
            set_env_value "$ENV_FILE" "cache.handler" "file"
            echo -e "${GREEN}OK${NC}"
        fi

        OK=$((OK + 1))
    done

    echo
    echo "=============================================================="
    echo "  SELESAI: $OK berhasil, $FAIL gagal/skip"
    echo "=============================================================="
    echo
    read -r -p "Tekan ENTER..."
}


# =====================================================
# FUNGSI TUNING PHPMYADMIN (UPLOAD LARGE FILE)
# =====================================================

tune_phpmyadmin() {
    local CLPINI="/home/clp/services/php-fpm/fpm/php.ini"
    local DATE
    DATE="$(date +%F_%H%M%S)"

    echo "=============================================================="
    echo "  TUNING PHPMYADMIN (Upload Large File)"
    echo "=============================================================="
    echo

    # 1. Cek CloudPanel & phpMyAdmin
    if [[ ! -f "$CLPINI" ]]; then
        echo -e "${RED}ERROR: CloudPanel PHP-FPM config tidak ditemukan:${NC}"
        echo "  $CLPINI"
        echo "  Pastikan CloudPanel terinstall."
        return 1
    fi

    echo "[INFO] PHP-FPM config: $CLPINI"
    echo

    # 2. Backup
    cp "$CLPINI" "${CLPINI}.backup.${DATE}" 2>/dev/null
    echo -e "${GREEN}Backup: ${CLPINI}.backup.${DATE}${NC}"
    echo

    # 3. Tampilkan config SEBELUM
    echo "--- SEBELUM ---"
    echo "  upload_max_filesize  : $(grep -E '^upload_max_filesize' "$CLPINI" 2>/dev/null | awk '{print $3}' || echo '(default 2M)')"
    echo "  post_max_size        : $(grep -E '^post_max_size' "$CLPINI" 2>/dev/null | awk '{print $3}' || echo '(default 8M)')"
    echo "  max_execution_time   : $(grep -E '^max_execution_time' "$CLPINI" 2>/dev/null | awk '{print $3}' || echo '(default 30)')"
    echo "  max_input_time       : $(grep -E '^max_input_time' "$CLPINI" 2>/dev/null | awk '{print $3}' || echo '(default 60)')"
    echo "  memory_limit         : $(grep -E '^memory_limit' "$CLPINI" 2>/dev/null | awk '{print $3}' || echo '(default 128M)')"
    echo

    # 4. Terapkan config baru
    echo "[INFO] Menerapkan config baru..."

    # Hapus baris lama yang bentrok
    sed -i '/^upload_max_filesize/d' "$CLPINI"
    sed -i '/^post_max_size/d' "$CLPINI"
    sed -i '/^max_execution_time/d' "$CLPINI"
    sed -i '/^max_input_time/d' "$CLPINI"
    sed -i '/^memory_limit/d' "$CLPINI"

    # Tulis config baru
    cat >> "$CLPINI" <<EOF

; ============================================================
; PHPMYADMIN TUNING (upload large file)
; ============================================================

upload_max_filesize = 1024M
post_max_size = 1024M
max_execution_time = 0
max_input_time = 0
memory_limit = 2048M
EOF

    # 5. Tampilkan config SESUDAH
    echo ""
    echo "--- SESUDAH ---"
    echo "  upload_max_filesize  : $(grep -E '^upload_max_filesize' "$CLPINI" | awk '{print $3}')"
    echo "  post_max_size        : $(grep -E '^post_max_size' "$CLPINI" | awk '{print $3}')"
    echo "  max_execution_time   : $(grep -E '^max_execution_time' "$CLPINI" | awk '{print $3}')"
    echo "  max_input_time       : $(grep -E '^max_input_time' "$CLPINI" | awk '{print $3}')"
    echo "  memory_limit         : $(grep -E '^memory_limit' "$CLPINI" | awk '{print $3}')"
    echo

    # 6. Tuning Nginx untuk phpMyAdmin (anti timeout)
    echo "[INFO] Tuning Nginx timeout untuk phpMyAdmin..."
    local PMA_CONF="/etc/nginx/conf.d/99-phpmyadmin-tuneup.conf"
    cat > "$PMA_CONF" <<'NGINX'
; PHPMYADMIN TIMEOUT TUNING
; Generated by dk.sh - prevent ERR_HTTP2_PING_FAILED

; Increase timeout untuk import besar
proxy_read_timeout 600s;
proxy_send_timeout 600s;
fastcgi_read_timeout 600s;
fastcgi_send_timeout 600s;
client_max_body_size 1024M;
NGINX
    echo -e "${GREEN}Nginx config: $PMA_CONF${NC}"

    # 7. Cek & set permission upload directory (jika ada)
    local PMA_UPLOAD_DIR="/var/www/phpmyadmin/upload"
    if [[ -d "$PMA_UPLOAD_DIR" ]]; then
        chmod 755 "$PMA_UPLOAD_DIR"
        echo -e "${GREEN}Upload dir: $PMA_UPLOAD_DIR (permission 755)${NC}"
    fi

    # 8. Restart PHP-FPM & Nginx
    echo ""
    echo "[INFO] Restarting services..."

    # Restart semua PHP-FPM yang aktif
    local RESTARTED=0
    for FPM in $(systemctl list-units --type=service --no-legend 2>/dev/null | grep -oE 'php[0-9.]+-fpm' | sort -u); do
        systemctl restart "$FPM" 2>/dev/null && { echo "  Restart $FPM ... OK"; RESTARTED=$((RESTARTED + 1)); }
    done

    # Coba restart phpMyAdmin-specific FPM jika ada
    for FPM_DIR in /etc/php/*/fpm/pool.d/ /home/clp/services/php-fpm/fpm/pool.d/; do
        if [[ -d "$FPM_DIR" ]]; then
            local FPMVER
            FPMVER="$(basename "$(dirname "$(dirname "$FPM_DIR")")")"
            if [[ "$FPMVER" =~ ^php ]] && systemctl is-active "php${FPMVER#php}-fpm" >/dev/null 2>&1; then
                systemctl restart "php${FPMVER#php}-fpm" 2>/dev/null && echo "  Restart php${FPMVER#php}-fpm ... OK"
            fi
        fi
    done

    # Validasi nginx config sebelum restart
    echo -ne "  Validating nginx config... "
    if nginx -t 2>/dev/null; then
        echo -e "${GREEN}OK${NC}"
        systemctl restart nginx 2>/dev/null && echo "  Restart nginx ... OK"
    else
        echo -e "${RED}ERROR - skip restart nginx${NC}"
        rm -f "$PMA_CONF"
        echo -e "${YELLOW}  Config nginx dibatalkan karena error.${NC}"
    fi

    echo ""
    echo -e "${GREEN}Tuning phpMyAdmin selesai!${NC}"
    echo -e "${YELLOW}Catatan: Jika masih timeout, coba import via command line:${NC}"
    echo "  zcat file.sql.gz | mysql -u root -p database_name"
    echo
    read -r -p "Tekan ENTER..."
}


# =====================================================
# MENU TUNING PHPMYADMIN
# =====================================================

menu_tune_phpmyadmin() {
    clear
    tune_phpmyadmin
    echo
    read -r -p "Tekan ENTER..."
}


# =====================================================
# VALIDASI AWAL
# =====================================================

echo "Validasi site user..."
VALIDASI_OK=true
declare -A SEEN_USERS

for DOMAIN in "${DOMAINS[@]}"; do
    SU="$(make_site_user "$DOMAIN" 2>/dev/null)" || { echo -e "${RED}ERROR: Domain tidak valid: $DOMAIN${NC}"; exit 1; }

    if [[ ! "$SU" =~ ^[a-z0-9]+$ ]]; then
        echo -e "${RED}ERROR: Site user tidak valid: $SU${NC}"; exit 1
    fi
    if (( ${#SU} > MAX_SITE_USER_LEN )); then
        echo -e "${RED}ERROR: Site user terlalu panjang: $SU (${#SU} > $MAX_SITE_USER_LEN)${NC}"; exit 1
    fi
    if [[ -n "${SEEN_USERS[$SU]+x}" ]]; then
        echo -e "${RED}ERROR: Site user duplikat: $SU${NC}"; exit 1
    fi
    SEEN_USERS["$SU"]=1
done

echo -e "${GREEN}Validasi OK.${NC}"
sleep 1


# =====================================================
# MENU IMPORT SQL
# =====================================================

menu_import_sql() {
    clear
    echo "=============================================================="
    echo "  IMPORT SQL KE DATABASE"
    echo "=============================================================="
    echo

    local IMPORT_DIR="/home/srv/importdb"

    # 1. Buat directory jika belum ada
    if [[ ! -d "$IMPORT_DIR" ]]; then
        echo -e "${YELLOW}Directory belum ada, membuat: $IMPORT_DIR${NC}"
        mkdir -p "$IMPORT_DIR"
        if [[ $? -ne 0 ]]; then
            echo -e "${RED}ERROR: Gagal membuat directory: $IMPORT_DIR${NC}"
            echo
            read -r -p "Tekan ENTER..."
            return 1
        fi
        echo -e "${GREEN}Directory dibuat: $IMPORT_DIR${NC}"
        echo "Upload file .sql.gz ke sana, lalu jalankan menu ini lagi."
        echo
        read -r -p "Tekan ENTER..."
        return 0
    fi

    # 2. List file .sql.gz
    echo "File .sql.gz di $IMPORT_DIR:"
    echo
    local FILES=()
    local i=1
    for f in "$IMPORT_DIR"/*.sql.gz; do
        [[ -f "$f" ]] || continue
        local BASENAME
        BASENAME="$(basename "$f")"
        local SIZE
        SIZE="$(du -h "$f" | awk '{print $1}')"
        echo -e "  ${GREEN}$i)${NC} $BASENAME ($SIZE)"
        FILES+=("$f")
        i=$((i + 1))
    done

    if [[ ${#FILES[@]} -eq 0 ]]; then
        echo -e "${YELLOW}Tidak ada file .sql.gz ditemukan di $IMPORT_DIR${NC}"
        echo "Upload file .sql.gz terlebih dahulu."
        echo
        read -r -p "Tekan ENTER..."
        return 1
    fi

    echo
    echo -e "${CYAN}--------------------------------------------${NC}"
    read -r -p "Pilih file [1-${#FILES[@]}]: " FILE_CHOICE

    if [[ ! "$FILE_CHOICE" =~ ^[0-9]+$ ]] || [[ "$FILE_CHOICE" -lt 1 ]] || [[ "$FILE_CHOICE" -gt ${#FILES[@]} ]]; then
        echo -e "${RED}Pilihan tidak valid!${NC}"
        sleep 1
        return 1
    fi

    local SELECTED_FILE="${FILES[$((FILE_CHOICE - 1))]}"
    local SELECTED_NAME
    SELECTED_NAME="$(basename "$SELECTED_FILE")"

    echo
    echo "File: $SELECTED_NAME"

    # 3. Pilih database
    echo
    echo "Database yang tersedia:"
    echo
    echo -e "  ${GREEN}1)${NC} $MASTER_DB (database master)"
    echo -e "  ${GREEN}2)${NC} Ketik manual"
    echo
    read -r -p "Pilih database [1/2]: " DB_CHOICE

    local TARGET_DB
    case "$DB_CHOICE" in
        1)
            TARGET_DB="$MASTER_DB"
            ;;
        2)
            read -r -p "Masukkan nama database: " TARGET_DB
            ;;
        *)
            echo -e "${RED}Pilihan tidak valid!${NC}"
            sleep 1
            return 1
            ;;
    esac

    if [[ -z "$TARGET_DB" ]]; then
        echo -e "${RED}ERROR: Nama database kosong!${NC}"
        sleep 1
        return 1
    fi

    # 4. Konfirmasi
    echo
    echo -e "${YELLOW}WARNING: Import akan menimpa data yang ada di database '$TARGET_DB'!${NC}"
    echo
    echo "File   : $SELECTED_NAME"
    echo "Database: $TARGET_DB"
    echo
    read -r -p "Lanjutkan import? (y/n): " CONFIRM
    [[ ! "$CONFIRM" =~ ^[Yy]$ ]] && { echo "Dibatalkan."; sleep 1; return 0; }

    # 5. Cek clpctl
    if ! command -v clpctl &>/dev/null; then
        echo -e "${RED}ERROR: clpctl tidak ditemukan!${NC}"
        echo "Pastikan CloudPanel terinstall."
        sleep 1
        return 1
    fi

    # 6. Import via CloudPanel
    echo
    echo "[INFO] Importing $SELECTED_NAME ke $TARGET_DB ..."
    echo "[INFO] File size: $(du -h "$SELECTED_FILE" | awk '{print $1}')"
    echo "[INFO] Menggunakan: clpctl db:import"
    echo "[INFO] Mohon tunggu, ini mungkin memakan waktu lama..."
    echo

    local START_TIME
    START_TIME=$(date +%s)

    clpctl db:import --databaseName="$TARGET_DB" --file="$SELECTED_FILE" 2>&1
    local EXIT_CODE=$?

    local END_TIME
    END_TIME=$(date +%s)
    local DURATION=$((END_TIME - START_TIME))
    local MINUTES=$((DURATION / 60))
    local SECONDS=$((DURATION % 60))

    echo
    if [[ $EXIT_CODE -eq 0 ]]; then
        echo -e "${GREEN}Import berhasil!${NC}"
        echo -e "${GREEN}Database: $TARGET_DB${NC}"
        echo -e "${GREEN}Waktu: ${MINUTES}m ${SECONDS}s${NC}"
    else
        echo -e "${RED}Import gagal! (exit code: $EXIT_CODE)${NC}"
        echo -e "${YELLOW}Coba manual:${NC}"
        echo "  clpctl db:import --databaseName=$TARGET_DB --file=$SELECTED_FILE"
    fi

    echo
    read -r -p "Tekan ENTER..."
}


# =====================================================
# MENU EXPORT DATABASE
# =====================================================

menu_export_database() {
    clear
    echo "=============================================================="
    echo "  EXPORT DATABASE"
    echo "=============================================================="
    echo

    # Cek clpctl
    if ! command -v clpctl &>/dev/null; then
        echo -e "${RED}ERROR: clpctl tidak ditemukan!${NC}"
        echo "Pastikan CloudPanel terinstall."
        echo
        read -r -p "Tekan ENTER..."
        return 1
    fi

    # 1. List database
    echo "Database tersedia:"
    echo
    echo -e "  ${GREEN}1)${NC} $MASTER_DB (database master)"
    echo -e "  ${GREEN}2)${NC} Ketik manual"
    echo
    read -r -p "Pilih database [1/2]: " DB_CHOICE

    local TARGET_DB
    case "$DB_CHOICE" in
        1)
            TARGET_DB="$MASTER_DB"
            ;;
        2)
            read -r -p "Masukkan nama database: " TARGET_DB
            ;;
        *)
            echo -e "${RED}Pilihan tidak valid!${NC}"
            sleep 1
            return 1
            ;;
    esac

    if [[ -z "$TARGET_DB" ]]; then
        echo -e "${RED}ERROR: Nama database kosong!${NC}"
        sleep 1
        return 1
    fi

    # 2. Setup
    local DATE
    DATE="$(date +%F_%H%M%S)"
    local BACKUP_DIR="/home/srv/backup_db"
    local BACKUP_FILE="${BACKUP_DIR}/${TARGET_DB}_${DATE}.sql.gz"

    mkdir -p "$BACKUP_DIR" 2>/dev/null

    # 3. Konfirmasi
    echo
    echo "Database : $TARGET_DB"
    echo "Output   : $BACKUP_FILE"
    echo
    read -r -p "Export database? (y/n): " CONFIRM
    [[ ! "$CONFIRM" =~ ^[Yy]$ ]] && { echo "Dibatalkan."; sleep 1; return 0; }

    # 4. Export
    echo
    echo "[INFO] Exporting database '$TARGET_DB'..."
    echo "[INFO] Mohon tunggu..."
    echo

    local START_TIME
    START_TIME=$(date +%s)

    clpctl db:export --databaseName="$TARGET_DB" --file="$BACKUP_FILE" 2>&1
    local EXIT_CODE=$?

    local END_TIME
    END_TIME=$(date +%s)
    local DURATION=$((END_TIME - START_TIME))
    local MINUTES=$((DURATION / 60))
    local SECONDS=$((DURATION % 60))

    echo
    if [[ $EXIT_CODE -eq 0 ]] && [[ -f "$BACKUP_FILE" ]]; then
        echo -e "${GREEN}Export berhasil!${NC}"
        echo -e "${GREEN}Database : $TARGET_DB${NC}"
        echo -e "${GREEN}File     : $BACKUP_FILE${NC}"
        echo -e "${GREEN}Size     : $(du -h "$BACKUP_FILE" | awk '{print $1}')${NC}"
        echo -e "${GREEN}Waktu    : ${MINUTES}m ${SECONDS}s${NC}"
    else
        echo -e "${RED}Export gagal! (exit code: $EXIT_CODE)${NC}"
        echo -e "${YELLOW}Coba manual:${NC}"
        echo "  clpctl db:export --databaseName=$TARGET_DB --file=$BACKUP_FILE"
    fi

    echo
    read -r -p "Tekan ENTER..."
}


# =====================================================
# MENU CLONE DATABASE
# =====================================================

menu_clone_database() {
    clear
    echo "=============================================================="
    echo "  CLONE DATABASE"
    echo "=============================================================="
    echo
    echo "Backup database source, lalu import ke database tujuan."
    echo

    # Cek clpctl
    if ! command -v clpctl &>/dev/null; then
        echo -e "${RED}ERROR: clpctl tidak ditemukan!${NC}"
        echo "Pastikan CloudPanel terinstall."
        echo
        read -r -p "Tekan ENTER..."
        return 1
    fi

    # 1. List database dari master
    echo "Database tersedia (dari master):"
    echo
    echo -e "  ${GREEN}1)${NC} $MASTER_DB (database master)"
    echo -e "  ${GREEN}2)${NC} Ketik manual"
    echo
    read -r -p "Pilih database source [1/2]: " SRC_CHOICE

    local SRC_DB
    case "$SRC_CHOICE" in
        1)
            SRC_DB="$MASTER_DB"
            ;;
        2)
            read -r -p "Masukkan nama database source: " SRC_DB
            ;;
        *)
            echo -e "${RED}Pilihan tidak valid!${NC}"
            sleep 1
            return 1
            ;;
    esac

    if [[ -z "$SRC_DB" ]]; then
        echo -e "${RED}ERROR: Nama database source kosong!${NC}"
        sleep 1
        return 1
    fi

    # 2. Database tujuan
    echo
    echo "Database tujuan:"
    echo
    echo -e "  ${GREEN}1)${NC} $MASTER_DB (database master)"
    echo -e "  ${GREEN}2)${NC} Ketik manual"
    echo
    read -r -p "Pilih database tujuan [1/2]: " DST_CHOICE

    local DST_DB
    case "$DST_CHOICE" in
        1)
            DST_DB="$MASTER_DB"
            ;;
        2)
            read -r -p "Masukkan nama database tujuan: " DST_DB
            ;;
        *)
            echo -e "${RED}Pilihan tidak valid!${NC}"
            sleep 1
            return 1
            ;;
    esac

    if [[ -z "$DST_DB" ]]; then
        echo -e "${RED}ERROR: Nama database tujuan kosong!${NC}"
        sleep 1
        return 1
    fi

    # Cek source = tujuan
    if [[ "$SRC_DB" == "$DST_DB" ]]; then
        echo -e "${RED}ERROR: Database source dan tujuan sama!${NC}"
        sleep 1
        return 1
    fi

    # 3. Konfirmasi
    echo
    echo -e "${YELLOW}WARNING: Database tujuan '$DST_DB' akan ditimpa!${NC}"
    echo
    echo "Source  : $SRC_DB"
    echo "Tujuan  : $DST_DB"
    echo
    read -r -p "Lanjutkan clone? (y/n): " CONFIRM
    [[ ! "$CONFIRM" =~ ^[Yy]$ ]] && { echo "Dibatalkan."; sleep 1; return 0; }

    # 4. Setup
    local DATE
    DATE="$(date +%F_%H%M%S)"
    local BACKUP_DIR="/home/srv/backup_db"
    local BACKUP_FILE="${BACKUP_DIR}/${SRC_DB}_${DATE}.sql.gz"

    mkdir -p "$BACKUP_DIR" 2>/dev/null

    local START_TIME
    START_TIME=$(date +%s)

    # 5. Export source
    echo
    echo "[1/2] Export database '$SRC_DB'..."
    echo "  File: $BACKUP_FILE"

    clpctl db:export --databaseName="$SRC_DB" --file="$BACKUP_FILE" 2>&1
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}Export gagal!${NC}"
        sleep 1
        return 1
    fi

    # Cek file backup
    if [[ ! -f "$BACKUP_FILE" ]]; then
        # Coba cari file dengan nama mirip
        BACKUP_FILE=$(ls -t "${BACKUP_DIR}/${SRC_DB}"*.sql.gz 2>/dev/null | head -1)
        if [[ -z "$BACKUP_FILE" ]]; then
            echo -e "${RED}ERROR: File backup tidak ditemukan!${NC}"
            sleep 1
            return 1
        fi
    fi

    echo -e "${GREEN}Export OK${NC}"
    echo "  Size: $(du -h "$BACKUP_FILE" | awk '{print $1}')"

    # 6. Import ke tujuan
    echo
    echo "[2/2] Import ke database '$DST_DB'..."

    clpctl db:import --databaseName="$DST_DB" --file="$BACKUP_FILE" 2>&1
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}Import gagal!${NC}"
        echo -e "${YELLOW}Backup tersimpan di: $BACKUP_FILE${NC}"
        sleep 1
        return 1
    fi

    local END_TIME
    END_TIME=$(date +%s)
    local DURATION=$((END_TIME - START_TIME))
    local MINUTES=$((DURATION / 60))
    local SECONDS=$((DURATION % 60))

    echo
    echo -e "${GREEN}Clone berhasil!${NC}"
    echo -e "${GREEN}Source  : $SRC_DB${NC}"
    echo -e "${GREEN}Tujuan  : $DST_DB${NC}"
    echo -e "${GREEN}Backup  : $BACKUP_FILE${NC}"
    echo -e "${GREEN}Waktu   : ${MINUTES}m ${SECONDS}s${NC}"
    echo
    read -r -p "Tekan ENTER..."
}


# =====================================================
# MENU FIX PERMISSIONS
# =====================================================

menu_fix_permissions() {
    clear
    echo "=============================================================="
    echo "  FIX PERMISSIONS (Ownership & Mode)"
    echo "=============================================================="
    echo
    echo "Memperbaiki:"
    echo "  - Owner: site_user:site_user"
    echo "  - Directory: 755"
    echo "  - File: 644"
    echo "  - Writable (cache, logs, etc): 775"
    echo

    if ! select_domains; then
        read -r -p "Tekan ENTER..."; return
    fi

    echo
    read -r -p "Fix permissions untuk ${#SELECTED[@]} domain terpilih? (y/n): " CONFIRM
    [[ ! "$CONFIRM" =~ ^[Yy]$ ]] && { echo "Dibatalkan."; return; }

    local OK=0 FAIL=0

    echo
    for CHOICE in "${SELECTED[@]}"; do
        local DOM="${DOMAINS[$((CHOICE - 1))]}"
        local SU DEST_ROOT

        SU="$(make_site_user "$DOM" 2>/dev/null)" || { FAIL=$((FAIL + 1)); continue; }
        DEST_ROOT="/home/${SU}/htdocs/${DOM}"

        if ! id "$SU" >/dev/null 2>&1; then
            echo -e "${RED}  SKIP: $DOM (site user '$SU' tidak ada)${NC}"
            FAIL=$((FAIL + 1))
            continue
        fi

        if [[ ! -d "$DEST_ROOT" ]]; then
            echo -e "${RED}  SKIP: $DOM (directory tidak ada)${NC}"
            FAIL=$((FAIL + 1))
            continue
        fi

        echo -e "${CYAN}  $DOM${NC} (owner: $SU)"

        # Buat writable directories jika belum ada
        echo -ne "    Create writable dirs... "
        mkdir -p "${DEST_ROOT}/writable/cache" \
                 "${DEST_ROOT}/writable/logs" \
                 "${DEST_ROOT}/writable/session" \
                 "${DEST_ROOT}/writable/debugbar" \
                 "${DEST_ROOT}/writable/imports" \
                 "${DEST_ROOT}/writable/uploads" 2>/dev/null
        echo -e "${GREEN}OK${NC}"

        # Fix ownership
        echo -ne "    Chown recursively... "
        chown -R "${SU}:${SU}" "$DEST_ROOT" 2>/dev/null
        echo -e "${GREEN}OK${NC}"

        # Fix directory permissions
        echo -ne "    Dir 755... "
        find "$DEST_ROOT" -type d -exec chmod 755 {} \; 2>/dev/null
        echo -e "${GREEN}OK${NC}"

        # Fix file permissions
        echo -ne "    File 644... "
        find "$DEST_ROOT" -type f -exec chmod 644 {} \; 2>/dev/null
        echo -e "${GREEN}OK${NC}"

        # Fix writable directories (775)
        echo -ne "    Writable 775... "
        find "${DEST_ROOT}/writable" -type d -exec chmod 775 {} \; 2>/dev/null
        echo -e "${GREEN}OK${NC}"

        # Fix .env permission (640)
        if [[ -f "${DEST_ROOT}/.env" ]]; then
            echo -ne "    .env 640... "
            chmod 640 "${DEST_ROOT}/.env" 2>/dev/null
            echo -e "${GREEN}OK${NC}"
        fi

        OK=$((OK + 1))
    done

    echo
    echo "=============================================================="
    echo "  SELESAI: $OK berhasil, $FAIL gagal/skip"
    echo "=============================================================="
    echo
    read -r -p "Tekan ENTER..."
}


# =====================================================
# MENU CLEAR DISK
# =====================================================

menu_clear_disk() {
    clear
    echo "=============================================================="
    echo "  CLEAR DISK (Hapus Backup + Cache)"
    echo "=============================================================="
    echo
    echo "Yang akan dibersihkan:"
    echo "  1. Backup update dari master (/home/*/backup_*)"
    echo "  2. Backup database lama (/home/srv/backup_db/*)"
    echo "  3. File import lama (/home/srv/importdb/*)"
    echo "  4. Clean cache (server + CI4)"
    echo

    echo "Disk saat ini:"
    df -h / | tail -1 | awk '{print "  Terpakai: "$3" / "$2" ("$5")"}'
    echo

    # 1. Hapus backup update
    echo "----------------------------------------------"
    echo "1) Backup update dari master:"
    local BK_DIRS=()
    local BK_COUNT=0
    while IFS= read -r dir; do
        [[ -d "$dir" ]] || continue
        local D_BASE
        D_BASE="$(basename "$dir")"
        [[ "$D_BASE" == backup_* ]] || continue
        local D_SIZE
        D_SIZE="$(du -sh "$dir" 2>/dev/null | awk '{print $1}')"
        BK_DIRS+=("$dir")
        BK_COUNT=$((BK_COUNT + 1))
        echo -e "    ${RED}[$BK_COUNT] $dir ($D_SIZE)${NC}"
    done < <(find /home -maxdepth 2 -type d -name "backup_*" 2>/dev/null | sort)

    if [[ "$BK_COUNT" -eq 0 ]]; then
        echo -e "    ${GREEN}(tidak ada backup)${NC}"
    else
        read -r -p "    Hapus ${BK_COUNT} backup ini? (y/n): " DEL_BK
        if [[ "$DEL_BK" =~ ^[Yy]$ ]]; then
            for dir in "${BK_DIRS[@]}"; do
                echo -ne "    Hapus $dir... "
                rm -rf "$dir" && echo -e "${GREEN}OK${NC}" || echo -e "${RED}GAGAL${NC}"
            done
            echo -e "    ${GREEN}Backup update dihapus.${NC}"
        fi
    fi

    # 2. Hapus backup DB lama
    echo "----------------------------------------------"
    echo "2) Backup database (/home/srv/backup_db):"
    local DB_FILES=()
    local DB_COUNT=0
    while IFS= read -r f; do
        [[ -f "$f" ]] || continue
        local DB_SIZE
        DB_SIZE="$(du -h "$f" 2>/dev/null | awk '{print $1}')"
        DB_FILES+=("$f")
        DB_COUNT=$((DB_COUNT + 1))
        echo -e "    ${RED}[$DB_COUNT] $(basename "$f") ($DB_SIZE)${NC}"
    done < <(find /home/srv/backup_db -type f -name "*.sql.gz" 2>/dev/null | sort)

    if [[ "$DB_COUNT" -eq 0 ]]; then
        echo -e "    ${GREEN}(tidak ada backup)${NC}"
    else
        read -r -p "    Hapus ${DB_COUNT} file ini? (y/n): " DEL_DB
        if [[ "$DEL_DB" =~ ^[Yy]$ ]]; then
            for f in "${DB_FILES[@]}"; do
                echo -ne "    Hapus $(basename "$f")... "
                rm -f "$f" && echo -e "${GREEN}OK${NC}" || echo -e "${RED}GAGAL${NC}"
            done
        fi
    fi

    # 3. Hapus file import lama
    echo "----------------------------------------------"
    echo "3) File import (/home/srv/importdb):"
    local IM_FILES=()
    local IM_COUNT=0
    while IFS= read -r f; do
        [[ -f "$f" ]] || continue
        local IM_SIZE
        IM_SIZE="$(du -h "$f" 2>/dev/null | awk '{print $1}')"
        IM_FILES+=("$f")
        IM_COUNT=$((IM_COUNT + 1))
        echo -e "    ${RED}[$IM_COUNT] $(basename "$f") ($IM_SIZE)${NC}"
    done < <(find /home/srv/importdb -type f \( -name "*.sql.gz" -o -name "*.sql" \) 2>/dev/null | sort)

    if [[ "$IM_COUNT" -eq 0 ]]; then
        echo -e "    ${GREEN}(tidak ada file)${NC}"
    else
        read -r -p "    Hapus ${IM_COUNT} file ini? (y/n): " DEL_IM
        if [[ "$DEL_IM" =~ ^[Yy]$ ]]; then
            for f in "${IM_FILES[@]}"; do
                echo -ne "    Hapus $(basename "$f")... "
                rm -f "$f" && echo -e "${GREEN}OK${NC}" || echo -e "${RED}GAGAL${NC}"
            done
        fi
    fi

    # 4. Clean cache (server + CI4)
    echo "----------------------------------------------"
    echo "4) Clean cache (server + CI4):"
    read -r -p "    Jalankan clean cache? (y/n): " DEL_CL
    if [[ "$DEL_CL" =~ ^[Yy]$ ]]; then
        clean_server_cache
        echo
        for DOMAIN in "${DOMAINS[@]}"; do
            clean_ci4_domain "$DOMAIN" 120
        done
    fi

    echo "----------------------------------------------"
    echo
    echo "Disk setelah dibersihkan:"
    df -h / | tail -1 | awk '{print "  Terpakai: "$3" / "$2" ("$5")"}'
    echo
    read -r -p "Tekan ENTER..."
}


# =====================================================
# MENU SISTEM INFO (DISK, MEMORY, CPU)
# =====================================================

menu_sysinfo() {
    clear
    echo "=============================================================="
    echo "  INFO SISTEM (Disk / Memory / CPU)"
    echo "=============================================================="
    echo

    # CPU
    echo ">>> CPU"
    local CPU_MODEL
    CPU_MODEL="$(grep -m1 "model name" /proc/cpuinfo 2>/dev/null | cut -d: -f2 | xargs)"
    local CPU_CORES
    CPU_CORES="$(nproc 2>/dev/null)"
    echo "  Model : $CPU_MODEL"
    echo "  Cores : $CPU_CORES Core"
    echo "  Load  : $(cat /proc/loadavg 2>/dev/null | awk '{print $1" "$2" "$3}') (1/5/15 mnt)"
    echo

    # Memory
    echo ">>> MEMORY (RAM)"
    local MEM_TOTAL MEM_USED MEM_FREE MEM_AVAIL
    MEM_TOTAL="$(free -m 2>/dev/null | awk '/^Mem:/{print $2}')"
    MEM_USED="$(free -m 2>/dev/null | awk '/^Mem:/{print $3}')"
    MEM_FREE="$(free -m 2>/dev/null | awk '/^Mem:/{print $4}')"
    MEM_AVAIL="$(free -m 2>/dev/null | awk '/^Mem:/{print $7}')"
    local MEM_TOTAL_H MEM_USED_H MEM_FREE_H MEM_AVAIL_H
    MEM_TOTAL_H="$(free -h 2>/dev/null | awk '/^Mem:/{print $2}')"
    MEM_USED_H="$(free -h 2>/dev/null | awk '/^Mem:/{print $3}')"
    MEM_FREE_H="$(free -h 2>/dev/null | awk '/^Mem:/{print $4}')"
    MEM_AVAIL_H="$(free -h 2>/dev/null | awk '/^Mem:/{print $7}')"
    echo "  Total : $MEM_TOTAL_H ($MEM_TOTAL MB)"
    echo "  Used  : $MEM_USED_H ($MEM_USED MB)"
    echo "  Free  : $MEM_FREE_H ($MEM_FREE MB)"
    echo "  Avail : $MEM_AVAIL_H ($MEM_AVAIL MB)"
    echo

    # Swap
    echo ">>> SWAP"
    local SW_TOTAL SW_USED SW_FREE
    SW_TOTAL="$(free -m 2>/dev/null | awk '/^Swap:/{print $2}')"
    SW_USED="$(free -m 2>/dev/null | awk '/^Swap:/{print $3}')"
    SW_FREE="$(free -m 2>/dev/null | awk '/^Swap:/{print $4}')"
    echo "  Total : $(( SW_TOTAL / 1024 )) GB"
    echo "  Used  : $(( SW_USED / 1024 )) GB"
    echo "  Free  : $(( SW_FREE / 1024 )) GB"
    echo

    # Disk
    echo ">>> DISK"
    df -hP / 2>/dev/null | tail -1 | awk '{print "  Root   : Total: "$2"  Used: "$3"  Free: "$4"  ("$5")"}'
    df -hP /home 2>/dev/null | tail -1 | awk '{print "  /home  : Total: "$2"  Used: "$3"  Free: "$4"  ("$5")"}'
    echo

    # Scan direktori besar
    echo ">>> Cari pemakan disk terbesar"
    echo " Lokasi scan:"
    echo "   1) / (root, semua)"
    echo "   2) /home (situs + user)"
    echo "   3) /var (log, cache, apt)"
    echo "   4) /usr, /opt (sistem)"
    echo
    read -r -p " Pilih lokasi scan [1-4, enter=skip]: " SCAN_LOC
    if [[ "$SCAN_LOC" =~ ^[1-4]$ ]]; then
        case "$SCAN_LOC" in
            1) local SCAN_PATH="/" ;;
            2) local SCAN_PATH="/home" ;;
            3) local SCAN_PATH="/var" ;;
            4) local SCAN_PATH="/usr /opt" ;;
        esac
        echo
        echo " Scanning (mohon tunggu, bisa beberapa menit)..."
        echo
        echo "  20 terbesar di lokasi tsb:"
        echo "  ---------------------------------------------"
        du -xS --block-size=1M "$SCAN_PATH" 2>/dev/null | sort -rn | head -20 | awk '
            {
                size=$1; $1=""
                if (size >= 1024) printf "  [%7.2f GB]%s\n", size/1024, $0
                else              printf "  [%7d MB]%s\n", size, $0
            }'
        echo "  ---------------------------------------------"
    fi

    echo "=============================================================="
    read -r -p "Tekan ENTER..."
}


# =====================================================
# MENU MYSQL DISK (Diagnosa + Purge BinLog)
# =====================================================

mysql_get_root_pw() {
    if [[ -n "${MYSQL_ROOT_PW:-}" ]]; then
        return 0
    fi
    MYSQL_ROOT_PW="$(clpctl db:show:master-credentials 2>/dev/null | awk -F'|' '
        tolower($2) ~ /pass(word)?/ {
            gsub(/[ |]/, "", $3)
            if ($3 != "") { print $3; exit }
        }')"
    if [[ -z "${MYSQL_ROOT_PW:-}" ]]; then
        MYSQL_ROOT_PW="$(clpctl db:show:master-credentials 2>/dev/null | grep -oP '(?i)(?:password|pass)\s*[:=]\s*\K\S+' | head -1)"
    fi
    if [[ -z "${MYSQL_ROOT_PW:-}" ]]; then
        read -r -s -p "  Masukkan MySQL root password: " MYSQL_ROOT_PW
        echo
    fi
}

# Jalankan query MySQL sebagai root via TCP (CloudPanel)
mysql_root() {
    mysql_get_root_pw
    mysql -h127.0.0.1 -P3306 -uroot -p"$MYSQL_ROOT_PW" -A "$@"
}

menu_mysql_disk() {
    clear
    echo "=============================================================="
    echo "  MYSQL DISK (Cek BinLog + Database)"
    echo "=============================================================="
    echo
    echo "Total /home/mysql : $(du -sh /home/mysql 2>/dev/null | awk '{print $1}')"
    echo

    # 1. File besar langsung di /home/mysql (bukan folder DB)
    echo "----------------------------------------------"
    echo "1) File besar langsung di /home/mysql (binlog/ibdata dll):"
    echo "  Size        Nama"
    find /home/mysql -maxdepth 1 -type f -printf '%s %f\n' 2>/dev/null \
        | sort -rn | head -15 \
        | awk '{ if ($1 >= 1073741824) printf "  [%7.2f GB] %s\n", $1/1073741824, $2
                 else if ($1 >= 1048576) printf "  [%7.1f MB] %s\n", $1/1048576, $2 }'
    echo

    # 2. Binary log
    echo "----------------------------------------------"
    echo "2) Binary log (mysql-bin):"
    local BIN_COUNT BIN_SIZE
    BIN_COUNT="$(find /home/mysql -maxdepth 1 -type f \( -name 'mysql-bin.*' -o -name 'binlog.*' \) 2>/dev/null | wc -l)"
    BIN_SIZE="$(find /home/mysql -maxdepth 1 -type f \( -name 'mysql-bin.*' -o -name 'binlog.*' \) 2>/dev/null -printf '%s\n' | awk '{s+=$1} END{printf "%.2f", s/1073741824}')"
    if [[ "$BIN_COUNT" -eq 0 ]] || [[ -z "$BIN_COUNT" ]]; then
        echo "  (tidak ada / binlog dinonaktifkan)"
    else
        echo "  Jumlah : $BIN_COUNT file"
        echo "  Total  : $BIN_SIZE GB"
        echo
        echo "  SETELAN BINLOG:"
        mysql_root -N -e \
          "SELECT @@log_bin, @@binlog_expire_logs_seconds, @@max_binlog_size;" \
          2>/dev/null \
          | awk '{print "   log_bin:"$1"  expire_sec:"$2"  max_size:"$3}'
    fi
    echo

    # 3. Database terbesar
    echo "----------------------------------------------"
    echo "3) 10 Database terbesar:"
    find /home/mysql -mindepth 1 -maxdepth 1 -type d ! -name '#*' \
        -printf '%f\n' 2>/dev/null | while read -r db; do
            dsz="$(du -sm "/home/mysql/$db" 2>/dev/null | awk '{print $1}')"
            [[ "$dsz" -gt 0 ]] && printf "%9d MB  %s\n" "$dsz" "$db"
        done | sort -rn | head -10
    echo

    echo "----------------------------------------------"
    echo "4) PURGE BINLOG lama:"
    if [[ "$BIN_COUNT" -gt 0 ]]; then
        echo "  Hapus binlog yang lebih lama dari N hari (disarankan 2-3 hari)."
        echo "  Server tidak bisa di-restore/patch lewat binlog untuk yang dihapus."
        read -r -p "  Jumlah hari untuk disimpan [3, 0=skip]: " BIN_DAYS
        if [[ "$BIN_DAYS" =~ ^[0-9]+$ ]] && [[ "$BIN_DAYS" -gt 0 ]]; then
            mysql_root -e \
              "PURGE BINARY LOGS BEFORE NOW() - INTERVAL $BIN_DAYS DAY; FLUSH BINARY LOGS;" \
              2>/dev/null && echo -e "  ${GREEN}Purge berhasil!${NC}" \
            || echo -e "  ${RED}Purge gagal (cek password / hak akses).${NC}"
            echo "  Total /home/mysql setelah purge: $(du -sh /home/mysql 2>/dev/null | awk '{print $1}')"
            BIN_COUNT=0
            BIN_SIZE="$(find /home/mysql -maxdepth 1 -type f \( -name 'mysql-bin.*' -o -name 'binlog.*' \) 2>/dev/null -printf '%s\n' | awk '{s+=$1} END{printf "%.2f", s/1073741824}')"
            echo "  Binlog tersisa: $BIN_SIZE GB"
        fi
    else
        echo "  (tidak ada binlog untuk di-purge)"
    fi
    echo

    echo "----------------------------------------------"
    echo "5) SETEL EXPIRY BINLOG otomatis (cegah numpuk lagi):"
    echo "  Set binlog otomatis dihapus setelah N hari. TANPA ini,"
    echo "  binlog akan menumpuk sampai penuh lagi."
    read -r -p "  Hari expiry [3, 0=skip]: " BIN_EXP
    if [[ "$BIN_EXP" =~ ^[0-9]+$ ]] && [[ "$BIN_EXP" -gt 0 ]]; then
        mysql_root -e \
          "SET GLOBAL binlog_expire_logs_seconds = $(( BIN_EXP * 86400 ));" \
          2>/dev/null && echo -e "  ${GREEN}GLOBAL set ke $BIN_EXP hari.${NC}" \
        || echo -e "  ${RED}Set GLOBAL gagal.${NC}"

        # Persist ke my.cnf agar permanen (MySQL 8 pakai binlog_expire_logs_seconds)
        local MYCNF=""
        for c in /etc/mysql/mysql.conf.d/mysqld.cnf /etc/mysql/my.cnf /etc/my.cnf; do
            [[ -f "$c" ]] && MYCNF="$c" && break
        done
        if [[ -n "$MYCNF" ]]; then
            if grep -q "binlog_expire_logs_seconds" "$MYCNF"; then
                sed -i "s/^binlog_expire_logs_seconds.*/binlog_expire_logs_seconds = $(( BIN_EXP * 86400 ))/" "$MYCNF"
            else
                echo "" >> "$MYCNF"
                echo "# Auto-set by dk.sh $(date +%Y-%m-%d_%H:%M:%S)" >> "$MYCNF"
                echo "binlog_expire_logs_seconds = $(( BIN_EXP * 86400 ))" >> "$MYCNF"
            fi
            echo -e "  ${GREEN}Persist ke $MYCNF. Berlaku permanen setelah restart.${NC}"
        else
            echo -e "  ${YELLOW}my.cnf tidak ditemukan, tambahkan manual:${NC}"
            echo "    [mysqld]"
            echo "    binlog_expire_logs_seconds = $(( BIN_EXP * 86400 ))"
        fi
    fi
    echo

    echo "----------------------------------------------"
    echo "6) NONAKTIFKAN BINLOG sepenuhnya (hemat ~30GB):"
    echo "  PERINGATAN: tanpa binlog, TIDAK bisa point-in-time"
    echo "  recovery / restore per-waktu (tepat ke jam)."
    echo "  Backup harian (mysqldump/clpctl) tetap aman."
    read -r -p "  Nonaktifkan binlog? [y/n, n=skip]: " BIN_OFF
    if [[ "$BIN_OFF" =~ ^[Yy]$ ]]; then
        # Bersihkan baris skip-log-bin yang salah di seluruh config mysql
        for f in /etc/mysql/my.cnf /etc/mysql/mysql.conf.d/*.cnf /etc/my.cnf; do
            [[ -f "$f" ]] || continue
            [[ "$f" == *zz-binlog-off.cnf ]] && continue
            sed -i '/^skip-[-_]log[-_]bin/d' "$f" 2>/dev/null
        done
        # Tulis ke file terpisah khusus [mysqld]
        if [[ -d /etc/mysql/mysql.conf.d ]]; then
            cat > /etc/mysql/mysql.conf.d/zz-binlog-off.cnf <<'EOF'
[mysqld]
# Binlog disabled by dk.sh
skip-log-bin
EOF
            echo -e "  ${GREEN}skip-log-bin ditulis di /etc/mysql/mysql.conf.d/zz-binlog-off.cnf${NC}"
        else
            printf '[mysqld]\n# Binlog disabled by dk.sh\nskip-log-bin\n' > /etc/mysql/zz-binlog-off.cnf
            echo -e "  ${GREEN}skip-log-bin ditulis di /etc/mysql/zz-binlog-off.cnf${NC}"
        fi
        echo -e "  ${YELLOW}PERLU RESTART MYSQL agar aktif.${NC}"
        read -r -p "  Restart MySQL sekarang? [y/n, n=manual]: " RESTART_MYSQL
        if [[ "$RESTART_MYSQL" =~ ^[Yy]$ ]]; then
            echo -e "  ${CYAN}Merestart MySQL...${NC}"
            systemctl restart mysql 2>/dev/null || service mysql restart 2>/dev/null
            sleep 3
            if pgrep -a mysqld >/dev/null 2>&1 || pgrep -a mariadbd >/dev/null 2>&1; then
                echo -e "  ${GREEN}MySQL sudah jalan kembali.${NC}"
            else
                echo -e "  ${RED}MySQL belum jalan. Cek: systemctl status mysql${NC}"
            fi
            # Cek log_bin sekarang
            LB_STATUS="$(mysql_root -N -e "SELECT @@log_bin;" 2>/dev/null | tr -d '[:space:]')"
            if [[ "$LB_STATUS" == "0" ]]; then
                echo -e "  ${GREEN}log_bin=OFF, aktif.${NC}"
                # Auto hapus file binlog lama sekarang
                BIN_OLD_COUNT="$(find /home/mysql -maxdepth 1 -type f \( -name 'mysql-bin.*' -o -name 'binlog.*' \) 2>/dev/null | wc -l)"
                if [[ "$BIN_OLD_COUNT" -gt 0 ]]; then
                    echo -e "  ${CYAN}Menghapus $BIN_OLD_COUNT file binlog lama...${NC}"
                    find /home/mysql -maxdepth 1 -type f \( -name 'mysql-bin.*' -o -name 'binlog.*' \) -delete 2>/dev/null
                    echo -e "  ${GREEN}File binlog lama dihapus.${NC}"
                    echo "  Total /home/mysql sekarang: $(du -sh /home/mysql 2>/dev/null | awk '{print $1}')"
                fi
            else
                echo -e "  ${RED}log_bin masih ON sesudah restart ($LB_STATUS). Cek skip-log-bin benar.${NC}"
            fi
        else
            echo -e "  ${YELLOW}Restart manual. Setelah restart, jalankan menu ini lagi dan pilih opsi 7.${NC}"
            # Coba purge binlog sekarang sebelum restart
            mysql_root -e "PURGE BINARY LOGS BEFORE NOW();" 2>/dev/null \
                && echo -e "  ${GREEN}Binlog dipurge sebelum restart.${NC}" \
                || echo -e "  ${YELLOW}Purge sekarang gagal; hapus file lama lewat opsi 7 setelah restart.${NC}"
        fi
    fi
    echo

    echo "----------------------------------------------"
    echo "7) HAPUS file binlog LAMA (setelah restart + skip-log-bin):"
    echo "  File binlog lama TIDAK otomatis dihapus oleh MySQL."
    echo "  Langkah ini menghapus fisik file binlog.* yang tersisa"
    echo "  (aman hanya jika log_bin sudah OFF / skip-log-bin aktif)."
    local LB_STATUS
    LB_STATUS="$(mysql_root -N -e "SELECT @@log_bin;" 2>/dev/null | tr -d '[:space:]')"
    if [[ "$LB_STATUS" == "0" ]]; then
        local BIN_OLD_COUNT BIN_OLD_SIZE
        BIN_OLD_COUNT="$(find /home/mysql -maxdepth 1 -type f \( -name 'mysql-bin.*' -o -name 'binlog.*' \) 2>/dev/null | wc -l)"
        BIN_OLD_SIZE="$(find /home/mysql -maxdepth 1 -type f \( -name 'mysql-bin.*' -o -name 'binlog.*' \) 2>/dev/null -printf '%s\n' | awk '{s+=$1} END{printf "%.2f", s/1073741824}')"
        echo "  Terdeteksi: $BIN_OLD_COUNT file ($BIN_OLD_SIZE GB) || log_bin=OFF (aman)"
        read -r -p "  Hapus file binlog lama ini? [y/n, n=skip]: " DEL_BIN
        if [[ "$DEL_BIN" =~ ^[Yy]$ ]]; then
            find /home/mysql -maxdepth 1 -type f \( -name 'mysql-bin.*' -o -name 'binlog.*' \) -delete 2>/dev/null
            echo -e "  ${GREEN}File binlog lama dihapus.${NC}"
            echo "  Total /home/mysql sekarang: $(du -sh /home/mysql 2>/dev/null | awk '{print $1}')"
        fi
    else
        echo -e "  ${RED}log_bin masih ON ($LB_STATUS). HAPUS DITOLAK.${NC}"
        echo "  Pastikan sudah restart MySQL setelah skip-log-bin, lalu coba lagi."
    fi
    echo

    echo "----------------------------------------------"
    echo
    read -r -p "Tekan ENTER..."
}


# =====================================================
# PILIH MASTER DOMAIN
# =====================================================

clear
select_master


# =====================================================
# MENU UTAMA
# =====================================================

while true; do

    clear

    echo "=============================================================="
    echo "       CLOUDPANEL CBT CI4 DEPLOYER (SMART)"
    echo "=============================================================="
    echo
    echo "SOURCE : $SOURCE_DOMAIN ($SOURCE_USER)"
    echo "DB     : $MASTER_DB / $MASTER_DB_USER"
    echo
    echo "PHP    : $PHP_VERSION"
    echo "PREFIX : $SITE_USER_PREFIX"
    echo "TOTAL  : ${#DOMAINS[@]} subdomain"
    echo
    echo "=============================================================="
    echo "MENU"
    echo "=============================================================="
    echo
    echo " 1) Clone Website"
    echo " 2) Install SSL"
    echo " 3) Mapping"
    echo " 4) Hapus Website"
    echo
    echo " --- SMART ---"
    echo
    echo " 5) Cek Status"
    echo " 6) Update dari Master"
    echo " 7) Fix Issues"
    echo " 8) Tune Up Server (MySQL + PHP + Nginx)"
    echo " 9) Cek Status Tune Up"
    echo "10) Clean Cache (Server + CI4)"
    echo "11) Migrate Master (spark migrate)"
    echo "12) Update .Env Custom (Database Credential)"
    echo "13) Tune phpMyAdmin (Upload Large File)"
    echo "14) Ganti Master Domain"
    echo "15) Import SQL ke Database"
    echo "16) Export Database"
    echo "17) Clone Database"
    echo "18) Fix Permissions"
    echo "19) Clear Disk (Backup + Cache)"
    echo "20) Info Sistem (Disk/Mem/CPU)"
    echo "21) MySQL Disk (Cek + Purge BinLog)"
    echo
    echo " 0) Keluar"
    echo
    echo "=============================================================="

    read -r -p "Pilih: " MENU

    case "$MENU" in
        1) menu_clone ;;
        2) menu_ssl ;;
        3) menu_mapping ;;
        4) menu_delete ;;
        5) menu_status ;;
        6) menu_update ;;
        7) menu_fix ;;
        8) menu_tuneup ;;
        9) menu_tune_status ;;
        10) menu_clean ;;
        11) menu_migrate ;;
        12) menu_update_env ;;
        13) menu_tune_phpmyadmin ;;
        14) select_master ;;
        15) menu_import_sql ;;
        16) menu_export_database ;;
        17) menu_clone_database ;;
        18) menu_fix_permissions ;;
        19) menu_clear_disk ;;
        20) menu_sysinfo ;;
        21) menu_mysql_disk ;;
        0) echo "Keluar."; exit 0 ;;
        *) echo -e "${RED}Menu tidak valid.${NC}"; sleep 1 ;;
    esac

done
