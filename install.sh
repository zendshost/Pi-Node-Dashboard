#!/bin/bash

# --- Memastikan skrip berjalan dengan hak akses root (sudo) ---
if [[ $EUID -ne 0 ]]; then
   echo "Skrip ini harus dijalankan sebagai root atau dengan sudo."
   exit 1
fi

echo "--- Memulai instalasi dan pengaturan Pi-Node-Dashboard ---"
echo ""

# 1. Menginstal npm menggunakan apt
echo "-> 1. Menginstal npm..."
apt update
apt install npm -y

# Memeriksa apakah instalasi npm berhasil
if [ $? -ne 0 ]; then
    echo "ERROR: Instalasi npm gagal. Hentikan skrip."
    exit 1
fi
echo "   npm berhasil diinstal."
echo ""

# 2. Menginstal PM2 secara global
echo "-> 2. Menginstal PM2 secara global..."
npm install pm2 -g
echo "   PM2 berhasil diinstal."
echo ""

# 3. Kloning repositori Git
echo "-> 3. Kloning repositori Pi-Node-Dashboard..."
git clone https://github.com/zendshost/Pi-Node-Dashboard.git

# Memeriksa apakah kloning berhasil
if [ $? -ne 0 ]; then
    echo "ERROR: Kloning repositori gagal. Hentikan skrip."
    exit 1
fi
echo "   Kloning berhasil."
echo ""

# 4. Pindah ke direktori dan menginstal dependensi Node.js
echo "-> 4. Pindah direktori dan menginstal dependensi Node.js..."
cd Pi-Node-Dashboard
npm i
echo "   Dependensi berhasil diinstal."
echo ""

# 5. Menjalankan server menggunakan PM2
echo "-> 5. Menjalankan server.js dengan PM2..."
pm2 start server.js

# Menampilkan status PM2
echo ""
echo "--- Status PM2: ---"
pm2 status

# 6. Menampilkan informasi akses
echo ""
echo "========================================================"
echo "✅ Instalasi selesai!"
echo "Server Running pada **IP:3000** (port default untuk Pi-Node-Dashboard)."
echo "Gunakan perintah 'pm2 logs' untuk melihat log server."
echo "========================================================"
