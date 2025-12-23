#!/usr/bin/env python3
"""
AWS sunucusunda çalışacak basit log gönderme scripti
Her AWS sunucusuna bu scripti koy, otomatik log gönderir
"""

import requests
import time
from datetime import datetime

# AYARLAR
BOT_TOKEN = "8525742123:AAH47p7YEfqC4NgXdcYzsM759ZbHmH_9QTI"
CHAT_ID = "989140810"
LOG_FILE = "/var/log/bilgi.log"  # Mining script'inin log yazdığı dosya
SERVER_NAME = "Server 1"  # Sunucu adını değiştir
ACCOUNT = "test@gmail.com"  # AWS hesap email
REGION = "us-east-1"  # Bölge

def send_telegram(message):
    """Telegram'a mesaj gönder"""
    url = f"https://api.telegram.org/bot{BOT_TOKEN}/sendMessage"
    payload = {"chat_id": CHAT_ID, "text": message, "parse_mode": "HTML"}
    try:
        requests.post(url, json=payload, timeout=10)
    except:
        pass

def get_region_name(region):
    """Bölge adı"""
    regions = {
        "us-east-1": "Virginia",
        "us-west-2": "Oregon",
        "eu-west-1": "Ireland"
    }
    return regions.get(region, region)

# Son okunan pozisyon
last_position = 0

print(f"Log gönderme başlatıldı: {SERVER_NAME}")

while True:
    try:
        # Log dosyasını oku
        with open(LOG_FILE, 'r', encoding='utf-8', errors='ignore') as f:
            f.seek(last_position)
            new_lines = f.readlines()
            last_position = f.tell()
        
        # Yeni loglar varsa gönder
        if new_lines:
            log_content = ''.join(new_lines[-5:]).strip()  # Son 5 satır
            if log_content:
                message = f"🔔 <b>Yeni Log - {SERVER_NAME}</b>\n"
                message += f"📧 {ACCOUNT}\n"
                message += f"🌍 {get_region_name(REGION)}\n"
                message += f"⏰ {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n\n"
                message += f"<code>{log_content}</code>"
                send_telegram(message)
        
        time.sleep(60)  # Her 1 dakikada bir kontrol et
        
    except FileNotFoundError:
        # Log dosyası henüz oluşmamış, bekle
        time.sleep(60)
    except Exception as e:
        print(f"Hata: {e}")
        time.sleep(60)

