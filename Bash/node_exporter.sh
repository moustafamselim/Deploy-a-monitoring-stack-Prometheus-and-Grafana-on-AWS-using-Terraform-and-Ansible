#!/bin/bash
#Install Node Exporter on Target Machines To scrape metrics

wget https://github.com/prometheus/node_exporter/releases/download/v1.8.2/node_exporter-1.8.2.linux-amd64.tar.gz

tar xvf node_exporter-1.8.2.linux-amd64.tar.gz

sudo cp node_exporter-1.8.2.linux-amd64/node_exporter /usr/local/bin/

echo "
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=root
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=default.target" | sudo tee /etc/systemd/system/node_exporter.service

sudo systemctl daemon-reload
sudo systemctl start node_exporter
sudo systemctl enable node_exporter

# node_exporter is available via `http://localhost:9100/metrics`