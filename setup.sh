#!/bin/bash

# ============================================
# AUTO PTERODACTYL INSTALLER - PREMIUM STYLE
# ============================================

# =============================
# RGB FUNCTION
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
# PROGRESS FROM OUTPUT
# =============================

run_with_progress() {
    cmd="$1"
    percent=0

    echo ""
    rgb_text "Memulai proses..."
    echo ""

    eval "$cmd" 2>&1 | while IFS= read -r line; do
        echo -ne "\rProgress: ["
        filled=$((percent / 2))
        for ((i=0;i<50;i++)); do
            if [ $i -lt $filled ]; then
                printf "\e[38;5;46m#\e[0m"
            else
                printf "-"
            fi
        done
        echo -ne "] $percent%%"

        if [[ $percent -lt 95 ]]; then
            ((percent++))
        fi
    done

    percent=100
    echo -ne "\rProgress: ["
    for ((i=0;i<50;i++)); do printf "\e[38;5;46m#\e[0m"; done
    echo "] 100%"
    echo "Selesai ✔"
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
# PIN PROTECTION
# =============================

CORRECT_PIN="RYZNAJA"   # <-- GANTI PIN

rgb_text "All in One Installer"
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
# PANEL
# =============================

install_panel() {
    rgb_text "INSTALL PANEL"
    run_with_progress "bash <(curl -s https://pterodactyl-installer.se)"
}

uninstall_panel() {
    rgb_text "UNINSTALL PANEL"
    run_with_progress "bash <(curl -s https://pterodactyl-installer.se) <<< 6"
}

# =============================
# NODE
# =============================

install_node() {
    rgb_text "INSTALL NODE/WINGS"
    run_with_progress "bash <(curl -s https://pterodactyl-installer.se)"
}

uninstall_node() {
    rgb_text "UNINSTALL NODE/WINGS"
    run_with_progress "bash <(curl -s https://pterodactyl-installer.se) <<< 5"
}

# =============================
# IMPORT EGG
# =============================

import_egg() {
    GITHUB_USER="ryznaja"
    GITHUB_REPO="autoimportegg"
    BRANCH="main"

    BASE_URL="https://raw.githubusercontent.com/$GITHUB_USER/$GITHUB_REPO/$BRANCH"

    clear
    rgb_text "Mengambil daftar egg..."

    mapfile -t eggs < <(curl -s https://api.github.com/repos/$GITHUB_USER/$GITHUB_REPO/contents | grep '"name":' | cut -d '"' -f4 | grep '.json')

    if [ ${#eggs[@]} -eq 0 ]; then
        echo "Tidak ada egg!"
        sleep 2
        return
    fi

    echo ""
    for i in "${!eggs[@]}"; do
        echo "$((i+1)). ${eggs[$i]}"
    done
    echo "0. Kembali"
    read -p "Pilih: " pilih

    if [ "$pilih" = "0" ]; then
        return
    fi

    EGG_FILE=${eggs[$((pilih-1))]}
    EGG_URL="$BASE_URL/$EGG_FILE"

    rgb_text "IMPORT $EGG_FILE"
    run_with_progress "php /var/www/pterodactyl/artisan p:eggs:import $EGG_URL"
}

# =============================
# AUTO ALLOCATION
# =============================

auto_allocation() {
    read -p "Node ID: " node
    read -p "Range port (8000-9000): " range
    rgb_text "MEMBUAT ALLOCATION"
    run_with_progress "php /var/www/pterodactyl/artisan p:allocation:make --node=$node --ip=$IPVPS --ports=$range"
}

# =============================
# THEME
# =============================

install_theme() {
    clear
    rgb_text "PILIH THEME"
    echo "1. Stellar"
    echo "2. Billing"
    echo "0. Kembali"
    read -p "Pilih: " t

    case $t in
        1)
            rgb_text "INSTALL STELLAR"
            run_with_progress "bash <(curl -s https://raw.githubusercontent.com/stellardev/theme/main/install.sh)"
            ;;
        2)
            rgb_text "INSTALL BILLING"
            run_with_progress "bash <(curl -s https://example.com/billing/install.sh)"
            ;;
        0) return ;;
    esac
}

uninstall_theme() {
    echo "Restore backup untuk hapus theme."
}

# =============================
# PROTECT
# =============================

install_protect() {
    read -p "Versi protect: " version
    rgb_text "INSTALL PROTECT"
    run_with_progress "bash <(curl -s https://raw.githubusercontent.com/Fdofficialcoyhost/Security-Pterodactyl/main/pr${version}.sh)"
}

uninstall_protect() {
    read -p "Versi protect: " version
    rgb_text "UNINSTALL PROTECT"
    run_with_progress "bash <(curl -s https://raw.githubusercontent.com/allzxy/Unprotect/refs/heads/main/un${version}.sh)"
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
    echo "5. Import Egg"
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
