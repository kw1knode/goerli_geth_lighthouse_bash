#!/bin/bash
cd ~
curl -LO https://gethstore.blob.core.windows.net/builds/geth-linux-amd64-1.10.25-69568c55.tar.gz
tar xvf geth-linux-amd64-1.10.25-69568c55.tar.gz
cd geth-linux-amd64-1.10.25-69568c55
sudo cp geth /usr/local/bin
cd ~
rm geth-linux-amd64-1.10.25-69568c55.tar.gz
rm -r geth-linux-amd64-1.10.25-69568c55
sudo useradd --no-create-home --shell /bin/false geth
sudo mkdir -p /var/lib/geth
sudo chown -R geth:geth /var/lib/geth

echo "[Unit]
Description=Geth Execution Client (Goerli Test Network)
After=network.target
Wants=network.target
[Service]
User=geth
Group=geth
Type=simple
Restart=always
RestartSec=5
ExecStart=/usr/local/bin/geth \
  --goerli \
  --datadir /var/lib/geth \
  --authrpc.jwtsecret /var/lib/jwtsecret/jwt.hex \
  --metrics \
  --metrics.addr 127.0.0.1
[Install]
WantedBy=default.target" >> /etc/systemd/system/geth.service \

sudo mkdir -p /var/lib/jwtsecret
openssl rand -hex 32 | sudo tee /var/lib/jwtsecret/jwt.hex > /dev/null
sudo systemctl daemon-reload
sudo systemctl start geth
sudo systemctl enable geth

cd ~
curl -LO https://github.com/sigp/lighthouse/releases/download/v3.1.0/lighthouse-v3.1.0-x86_64-unknown-linux-gnu.tar.gz
tar xvf lighthouse-v3.1.0-x86_64-unknown-linux-gnu.tar.gz
sudo cp lighthouse /usr/local/bin
rm lighthouse-v3.1.0-x86_64-unknown-linux-gnu.tar.gz
rm lighthouse
sudo useradd --no-create-home --shell /bin/false lighthousebeacon
sudo mkdir -p /var/lib/lighthouse/beacon
sudo chown -R lighthousebeacon:lighthousebeacon /var/lib/lighthouse/beacon


echo "[Unit]
Description=Lighthouse Consensus Client BN (Goerli Test Network)
Wants=network-online.target
After=network-online.target
[Service]
User=lighthousebeacon
Group=lighthousebeacon
Type=simple
Restart=always
RestartSec=5
ExecStart=/usr/local/bin/lighthouse bn \
  --network goerli \
  --datadir /var/lib/lighthouse \
  --http \
  --execution-endpoint http://localhost:8551 \
  --execution-jwt /var/lib/jwtsecret/jwt.hex \
  --checkpoint-sync-url https://goerli.checkpoint-sync.ethdevops.io \
  --metrics
[Install]
WantedBy=multi-user.target" >> /etc/systemd/system/lighthousebeacon.service \

sudo systemctl daemon-reload
sudo systemctl start geth
sudo systemctl enable geth
sudo systemctl start lighthousebeacon
sudo systemctl enable lighthousebeacon





