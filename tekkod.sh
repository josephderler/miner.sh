apt-get update -y
apt install screen -y
wget https://github.com/xmrig/xmrig/releases/download/v6.24.0/xmrig-6.24.0-linux-static-x64.tar.gz 
tar -xf xmrig-6.24.0-linux-static-x64.tar.gz
cd xmrig-6.24.0-linux-static-x64
screen -dmS mine ./xmrig-6.24.0/xmrig --donate-level 1 -o de.qrl.herominers.com:1166 -u Q0105001970d665f516c28f7317147eb34b181d40bc23f521d8c38bda97d95af3c7df047c61737d

