#!/bin/bash

# ==========================================
# Pi Node Dashboard - Remote Auto Installer
# ==========================================

green="\e[32m"
yellow="\e[33m"
red="\e[31m"
cyan="\e[36m"
reset="\e[0m"

echo -e "${cyan}"
echo "=========================================="
echo "   Pi Node Dashboard - Auto Installer"
echo "=========================================="
echo -e "${reset}"

# ------------------------------
# Require root
# ------------------------------
if [[ $EUID -ne 0 ]]; then
   echo -e "${red}❌ ERROR: Skrip harus dijalankan sebagai sudo / root.${reset}"
   exit 1
fi

# ------------------------------
# Install dependencies
# ------------------------------
echo -e "${yellow}→ Update system...${reset}"
apt update -y

echo -e "${yellow}→ Install Node.js 18 LTS...${reset}"
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt install -y nodejs git

if ! command -v node >/dev/null 2>&1; then
    echo -e "${red}❌ Node.js gagal dipasang!${reset}"
    exit 1
fi
echo -e "${green}✔ Node.js installed: $(node -v)${reset}"

echo -e "${yellow}→ Install PM2...${reset}"
npm install -g pm2
echo -e "${green}✔ PM2 installed.${reset}"

# ------------------------------
# Clone or update repository
# ------------------------------
if [ -d "Pi-Node-Dashboard" ]; then
    echo -e "${yellow}→ Directory found. Updating repository...${reset}"
    cd Pi-Node-Dashboard
    git pull
else
    echo -e "${yellow}→ Cloning Pi-Node-Dashboard...${reset}"
    git clone https://github.com/zendshost/Pi-Node-Dashboard.git
    cd Pi-Node-Dashboard
fi

echo -e "${green}✔ Repository ready.${reset}"

# ------------------------------
# Install NPM dependencies
# ------------------------------
echo -e "${yellow}→ Installing dependencies (npm install)...${reset}"
npm install >/dev/null 2>&1
echo -e "${green}✔ Dependencies installed.${reset}"

# ------------------------------
# Run with PM2
# ------------------------------
echo -e "${yellow}→ Starting dashboard with PM2...${reset}"

pm2 delete pi-dashboard >/dev/null 2>&1
pm2 start server.js --name pi-dashboard
pm2 save >/dev/null
pm2 startup systemd -u $USER --hp $HOME >/dev/null

echo -e "${green}✔ PM2 service created.${reset}"

# ------------------------------
# Detect server IP
# ------------------------------
SERVER_IP=$(hostname -I | awk '{print $1}')
[ -z "$SERVER_IP" ] && SERVER_IP="YOUR-SERVER-IP"

echo -e "${cyan}"
echo "=========================================="
echo "   🎉 INSTALL COMPLETE!"
echo "=========================================="
echo -e "${reset}"

echo -e "${green}Dashboard dapat dibuka: ${yellow}http://$SERVER_IP:3000${reset}"

echo ""
echo -e "${cyan}PM2 Commands:${reset}"
echo "  pm2 status"
echo "  pm2 logs pi-dashboard"
echo "  pm2 restart pi-dashboard"
echo ""
echo -e "${green}Auto installer by zendshost.id${reset}"
