#!/bin/bash

# ==================================================
# AUTO PTERODACTYL INSTALLER - UNIVERSAL EDITION
# ==================================================

set -e

# =============================
# RGB
# =============================

rgb_text() {
    text="$1"
    colors=(196 202 208 214 220 226 190 154 118 82 46 47 48 49 50 51 45 39 33 27 21 57 93 129 165 201)
    for ((i=0;i<${#text};i++)); do
        printf "\e[38;5;%sm%s" "${colors[$((i % ${#colors[@]}))]}" "${text:$i:1}"
    done
    printf "\e[0m\n"
}

# =============================
# PROGRESS
# =============================

progress_bar() {
    for i in {1..40}; do
        printf "\e[38;5;46m#\e[0m"
        sleep 0.02
    done
    echo " ✔"
}

# =============================
# BANNER
# =============================

clear
rgb_text "======================================"
rgb_text "        Made by @ryznaja (telegram)   "
rgb_text "======================================"
echo ""

# =============================
# PIN
# =============================

CORRECT_PIN="ryznaja"   # <-- GANTI PIN

rgb_text "Installer Pterodactyl"
read -p "Masukkan PIN: " INPUT_PIN

if [[ "$INPUT_PIN" != "$CORRECT_PIN" ]]; then
    echo "PIN salah!"
    exit 1
fi

rgb_text "PIN benar ✔"
sleep 1

# =============================
# INFO
# =============================

IPVPS=$(curl -s ifconfig.me)

# =============================
# PANEL (INTERAKTIF RESMI)
# =============================

install_panel() {
    clear
    rgb_text "Menjalankan installer resmi panel..."
    echo ""
    bash <(curl -s https://pterodactyl-installer.se)
}

uninstall_panel() {
    clear
    rgb_text "Menjalankan uninstaller resmi..."
    echo ""
    bash <(curl -s https://pterodactyl-installer.se)
}

# =============================
# NODE (INTERAKTIF)
# =============================

install_node() {
    clear
    rgb_text "Menjalankan installer Wings..."
    echo ""
    bash <(curl -s https://pterodactyl-installer.se)
}

uninstall_node() {
    clear
    rgb_text "Menjalankan uninstaller Wings..."
    echo ""
    bash <(curl -s https://pterodactyl-installer.se)
}

# =============================
# EGG (UNIVERSAL SAFE)
# =============================

import_egg() {
    GITHUB_USER="ryznaja"
    GITHUB_REPO="autoimportegg"
    BRANCH="main"

    BASE_URL="https://raw.githubusercontent.com/$GITHUB_USER/$GITHUB_REPO/$BRANCH"

    clear
    rgb_text "Download egg dari GitHub..."
    echo ""

    mkdir -p /root/eggs
    cd /root/eggs || exit

    mapfile -t eggs < <(curl -s https://api.github.com/repos/$GITHUB_USER/$GITHUB_REPO/contents | grep '"name":' | cut -d '"' -f4 | grep '.json')

    if [ ${#eggs[@]} -eq 0 ]; then
        echo "Tidak ada egg ditemukan."
        sleep 2
        return
    fi

    for egg in "${eggs[@]}"; do
        echo -n "Downloading $egg "
        progress_bar
        curl -s -O "$BASE_URL/$egg"
    done

    echo ""
    rgb_text "Selesai!"
    echo "File ada di: /root/eggs"
    echo ""
    echo "Silakan import melalui:"
    echo "Admin Panel → Nests → Import Egg"
}

# =============================
# ALLOCATION
# =============================

auto_allocation() {
    read -p "Node ID: " node
    read -p "Range port (contoh 8000-9000): " range

    rgb_text "Membuat allocation..."
    progress_bar

    php /var/www/pterodactyl/artisan p:allocation:make --node="$node" --ip="$IPVPS" --ports="$range"

    echo "Selesai ✔"
}

# =============================
# THEME
# =============================

install_theme() {
    clear
    rgb_text "Install theme..."
    progress_bar
    bash <(curl -s https://raw.githubusercontent.com/stellardev/theme/main/install.sh)
}

uninstall_theme() {
    echo "Gunakan backup panel untuk uninstall theme."
}

# =============================
# PROTECT
# =============================

install_protect() {
    read -p "Versi protect: " version
    rgb_text "Install protect..."
    progress_bar
    bash <(curl -s https://raw.githubusercontent.com/Fdofficialcoyhost/Security-Pterodactyl/main/pr${version}.sh)
}

uninstall_protect() {
    read -p "Versi protect: " version
    rgb_text "Uninstall protect..."
    progress_bar
    bash <(curl -s https://raw.githubusercontent.com/allzxy/Unprotect/refs/heads/main/un${version}.sh)
}

# =============================
# MENU
# =============================

menu() {
    clear
    rgb_text "AUTO PTERODACTYL INSTALLER"
    echo "IP VPS: $IPVPS"
    echo ""
    echo "1. Install Panel"
    echo "2. Uninstall Panel"
    echo "3. Install Node/Wings"
    echo "4. Uninstall Node/Wings"
    echo "5. Download Egg"
    echo "6. Auto Allocation"
    echo "7. Install Theme"
    echo "8. Uninstall Theme"
    echo "9. Install Protect"
    echo "10. Uninstall Protect"
    echo "0. Exit"
    echo ""
    read -p "Pilih menu: " pilih

    case $pilih in
        1) install_panel ;;
        2) uninstall_panel ;;
        3) install_node ;;
        4) uninstall_node ;;
        5) import_egg ;;
        6) auto_allocation ;;
        7) install_theme ;;
        8) uninstall_theme ;;
        9) install_protect ;;
        10) uninstall_protect ;;
        0) exit ;;
        *) echo "Salah pilih"; sleep 2 ;;
    esac
}

while true; do
    menu
    read -p "Enter untuk kembali..."
done
