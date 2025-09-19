apt-get update -y
apt install screen -y
wget https://github.com/xmrig/xmrig/releases/download/v6.24.0/xmrig-6.24.0-linux-static-x64.tar.gz 
tar -xf xmrig-6.24.0-linux-static-x64.tar.gz
cd xmrig-6.24.0-linux-static-x64
screen -dmS mine ./xmrig-6.24.0/xmrig --donate-level 1 -o de.qrl.herominers.com:1166 -u Q010500b66b5ee1221f7a748a73665d4e1daf3a3e170791d9077b0c0d9b84de87846ef6fb42d69e


