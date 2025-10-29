#!/bin/bash
# DERO Miner Otomatik Başlatma Scripti (screen içinde)
# Versiyon: josephderler/tek.sh uyumlu
# Node: 91.98.80.16:10102

# Hata olursa scripti durdur
set -e

# Gerekli bağımlılıklar
apt-get update -y
apt-get install screen wget -y

# Miner indir
wget -q https://github.com/deroproject/derohe/releases/latest/download/dero_linux_amd64.tar.gz -O dero_miner.tar.gz
tar -xvzf dero_miner.tar.gz
cd dero_linux_amd64

# Çalıştırma izni ver
chmod +x dero-miner-linux-amd64

# Eski screen varsa kapat
screen -S dero -X quit 2>/dev/null || true

# CPU çekirdek sayısını al
threads=$(nproc)

# Miner'ı screen içinde başlat
screen -dmS dero ./dero-miner-linux-amd64 \
--wallet-address dero1qypgrnglnxtv2f2f3uy25ra4a9dq9jpka2s4wv2u0lt5h8rrmrylzqqv2z2lj \
--daemon-rpc-address 91.98.80.16:10102 \
--mining-threads $threads

echo "✅ DERO Miner başlatıldı (screen: dero)"
echo "🔍 Durumu görmek için: screen -r dero"
echo "📤 Arka plana almak için: CTRL + A, sonra D"
echo "❌ Durdurmak için: screen -S dero -X quit"
