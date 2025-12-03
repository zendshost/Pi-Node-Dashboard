#!/bin/bash

# ==========================================
#  Pi Node Dashboard - Auto Installer (Pro)
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
# Check root
# ------------------------------
if [[ $EUID -ne 0 ]]; then
   echo -e "${red}ERROR: Jalankan dengan sudo atau root.${reset}"
   exit 1
fi

# ------------------------------
# Update system
# ------------------------------
echo -e "${yellow}→ Update system...${reset}"
apt update -y

# ------------------------------
# Install Node.js LTS (18.x)
# ------------------------------
echo -e "${yellow}→ Install Node.js 18 LTS...${reset}"

curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt install -y nodejs

if ! command -v node &> /dev/null; then
    echo -e "${red}ERROR: Node.js gagal diinstal.${reset}"
    exit 1
fi

echo -e "${green}✔ Node.js terinstal (versi: $(node -v))${reset}"
echo ""

# ------------------------------
# Install PM2
# ------------------------------
echo -e "${yellow}→ Install PM2...${reset}"
npm install -g pm2 &>/dev/null

echo -e "${green}✔ PM2 terinstal${reset}"
echo ""

# ------------------------------
# Clone Repo
# ------------------------------

if [ -d "Pi-Node-Dashboard" ]; then
    echo -e "${yellow}→ Folder Pi-Node-Dashboard sudah ada. Mengupdate repo...${reset}"
    cd Pi-Node-Dashboard
    git pull
else
    echo -e "${yellow}→ Clone repository Pi-Node-Dashboard...${reset}"
    git clone https://github.com/zendshost/Pi-Node-Dashboard.git
    cd Pi-Node-Dashboard
fi

echo -e "${green}✔ Repository siap${reset}"
echo ""

# ------------------------------
# Install Dependencies
# ------------------------------
echo -e "${yellow}→ Install dependencies (npm install)...${reset}"

npm install &>/dev/null

echo -e "${green}✔ Dependencies terinstal${reset}"
echo ""

# ------------------------------
# Start Server via PM2
# ------------------------------
echo -e "${yellow}→ Menjalankan server dengan PM2...${reset}"

pm2 delete pi-dashboard &>/dev/null
pm2 start server.js --name pi-dashboard

pm2 save
pm2 startup systemd -u $USER --hp $HOME >/dev/null

echo -e "${green}✔ PM2 berjalan sebagai service${reset}"
echo ""

# ------------------------------
# Get Server IP
# ------------------------------
SERVER_IP=$(hostname -I | awk '{print $1}')

echo -e "${cyan}"
echo "=========================================="
echo "   🎉 INSTALASI SELESAI!"
echo "=========================================="
echo -e "${reset}"

echo -e "${green}Dashboard dapat diakses di:${reset}"
echo -e "${yellow}http://$SERVER_IP:3000${reset}"
echo ""

echo -e "${cyan}PM2 Commands:${reset}"
echo "  pm2 status"
echo "  pm2 logs pi-dashboard"
echo "  pm2 restart pi-dashboard"
echo ""

echo -e "${green}Selesai! Dashboard berjalan otomatis 24/7 🎯${reset}"
