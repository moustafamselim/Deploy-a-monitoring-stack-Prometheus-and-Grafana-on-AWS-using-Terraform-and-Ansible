#!/bin/bash

# Install and Configure Monitoring Stack as Service [Prometheus, Grafana, Alert, Manager]

sudo apt update && sudo apt upgrade -y

sudo useradd --no-create-home --shell /bin/false prometheus

sudo mkdir /etc/prometheus

sudo mkdir /var/lib/prometheus

# Download Prometheus LTS Version 
# https://prometheus.io/download/

wget https://github.com/prometheus/prometheus/releases/download/v2.53.3/prometheus-2.53.3.linux-amd64.tar.gz

tar -xvf prometheus-2.53.3.linux-amd64.tar.gz

cd prometheus-2.53.3.linux-amd64

sudo cp prometheus /usr/local/bin/

sudo cp promtool /usr/local/bin/

sudo cp -r consoles /etc/prometheus

sudo cp -r console_libraries /etc/prometheus

sudo cp prometheus.yml /etc/prometheus/

sudo chown -R prometheus:prometheus /etc/prometheus /var/lib/prometheus

sudo chown prometheus:prometheus /usr/local/bin/prometheus /usr/local/bin/promtool

# Create Prometheus Service and integrate it with SystemD
echo "
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus --config.file=/etc/prometheus/prometheus.yml --storage.tsdb.path=/var/lib/prometheus --web.console.templates=/etc/prometheus/consoles --web.console.libraries=/etc/prometheus/console_libraries

[Install]
WantedBy=multi-user.target " | sudo tee /etc/systemd/system/prometheus.service

sudo systemctl daemon-reload

sudo systemctl start prometheus

sudo systemctl enable prometheus

#sudo systemctl status prometheus

#Prometheus will be available at `http://<your-server-ip>:9090

# ------------------------------------------------------------------------------------------------------------------------------ #

#Install and Configure Alertmanager

sudo mkdir /etc/alertmanager

sudo mkdir /var/lib/alertmanager

wget https://github.com/prometheus/alertmanager/releases/download/v0.28.0/alertmanager-0.28.0.linux-amd64.tar.gz

tar -xvf alertmanager-0.28.0.linux-amd64.tar.gz

cd alertmanager-0.28.0.linux-amd64

sudo cp alertmanager /usr/local/bin/

sudo cp amtool /usr/local/bin/

sudo cp alertmanager.yml /etc/alertmanager/

sudo chown -R prometheus:prometheus /etc/alertmanager /var/lib/alertmanager

#Integrate Alertmanager with SystemD

echo "
[Unit]
Description=Prometheus Alertmanager
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/alertmanager --config.file=/etc/alertmanager/alertmanager.yml --storage.path=/var/lib/alertmanager

[Install]
WantedBy=multi-user.target"  | sudo tee /etc/systemd/system/alertmanager.service

sudo systemctl daemon-reload
sudo systemctl start alertmanager
sudo systemctl enable alertmanager

#Alertmanager will be available at `http://<your-server-ip>:9093`

#-------------------------------------------------------------------------------------------------------------------------------------#

#Install and Configure Grafana

sudo apt-get install -y software-properties-common

sudo apt-get install -y apt-transport-https

sudo apt-get update -y

wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -

sudo add-apt-repository "deb https://packages.grafana.com/oss/deb stable main"

sudo apt-get update -y

sudo apt install grafana -y

sudo systemctl start grafana-server

#sudo systemctl status grafana-server

sudo systemctl enable grafana-server

#Grafana will be available at http://<your-server-ip>:3000.

#------------------------------------------------------------------------------------------------------------------#

sudo nano /etc/prometheus/prometheus.yml

sudo systemctl restart prometheus


