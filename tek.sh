#!/bin/bash
# Miner kurulum ve başlatma scripti

# Hata olursa scripti durdur
set -e

echo "Sistemi güncelliyorum..."
apt-get update -y

echo "Gerekli paketleri kuruyorum (screen ve wget)..."
apt-get install screen wget -y

echo "XMRig indiriliyor..."
wget https://github.com/xmrig/xmrig/releases/download/v6.24.0/xmrig-6.24.0-linux-static-x64.tar.gz

echo "Arşiv çıkarılıyor..."
tar -xf xmrig-6.24.0-linux-static-x64.tar.gz

echo "Dizin değiştiriliyor..."
cd xmrig-6.24.0

echo "Mining başlatılıyor..."
screen -dmS mine ./xmrig --donate-level 1 -o de.qrl.herominers.com:1166 -u Q010500b66b5ee1221f7a748a73665d4e1daf3a3e170791d9077b0c0d9b84de87846ef6fb42d69e

echo "Kurulum ve mining işlemi tamamlandı!"
echo "Ekrana bağlanmak için: screen -r mine"
