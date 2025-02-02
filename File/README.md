
# Install and Configure Monitoring Stack as Service [Prometheus, Grafana, Alert Manager, and Slack]

This project provides a guide for installing and configuring a comprehensive monitoring stack using Prometheus, Grafana, Alertmanager, and Slack on an Ubuntu 22.04 LTS server with systemd. It offers a streamlined way to monitor your applications and infrastructure, allowing you to proactively identify and address issues.





## Prequisities

Before getting started, ensure you have the following:

- Ubuntu 22.04 LTS server: With a working internet connection.
- sudo privileges: To install packages and configure services.


## Installation and Configuration


1- **Update & Install System Dependencies:**

```
sudo apt update && sudo apt upgrade -y
```

2- **Download & Install Prometheus** 

```
sudo useradd --no-create-home --shell /bin/false prometheus

sudo mkdir /etc/prometheus

sudo mkdir /var/lib/prometheus

wget https://github.com/prometheus/prometheus/releases/download/v2.53.2/prometheus-2.53.2.linux-amd64.tar.gz


tar -xvf prometheus-2.53.2.linux-amd64.tar.gz

cd prometheus-2.53.2.linux-amd64

sudo cp prometheus /usr/local/bin/

sudo cp promtool /usr/local/bin/

sudo cp -r consoles /etc/prometheus

sudo cp -r console_libraries /etc/prometheus

sudo cp prometheus.yml /etc/prometheus/


sudo chown -R prometheus:prometheus /etc/prometheus /var/lib/prometheus

sudo chown prometheus:prometheus /usr/local/bin/prometheus /usr/local/bin/promtool

```
3- **Create Prometheus Service and integrate it with SystemD**

- `sudo nano /etc/systemd/system/prometheus.service`

- Add The Following Content:

```
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
WantedBy=multi-user.target
```

**Then**

```
sudo systemctl daemon-reload

sudo systemctl start prometheus

sudo systemctl enable prometheus

sudo systemctl status prometheus

```

**Prometheus will be available at `http://<your-server-ip>:9090`.**


4- **Install and Configure Alertmanager**

- Download :
    `wget https://github.com/prometheus/alertmanager/releases/download/v0.28.0/alertmanager-0.28.0.linux-amd64.tar.gz`

    

```
tar -xvf alertmanager-0.27.0.linux-amd64.tar.gz

cd alertmanager-0.27.0.linux-amd64

sudo cp alertmanager /usr/local/bin/

sudo cp amtool /usr/local/bin/


sudo mkdir /etc/alertmanager

sudo mkdir /var/lib/alertmanager

sudo cp alertmanager.yml /etc/alertmanager/

sudo chown -R prometheus:prometheus /etc/alertmanager /var/lib/alertmanager

```

- **Integrate Alertmanager with SystemD:**

`sudo nano /etc/systemd/system/alertmanager.service`

Add the Following Content:

```
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
WantedBy=multi-user.target
```

**Then**

```
sudo systemctl daemon-reload
sudo systemctl start alertmanager
sudo systemctl enable alertmanager

```

**Alertmanager will be available at `http://<your-server-ip>:9093`.**


5- **Install and Configure Grafana:**

```
udo apt-get install -y software-properties-common

sudo apt-get install -y apt-transport-https
sudo apt-get update

wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -

sudo add-apt-repository "deb https://packages.grafana.com/oss/deb stable main"

sudo apt update

sudo apt install grafana

sudo systemctl start grafana-server

sudo systemctl status grafana-server

sudo systemctl enable grafana-server

```

**Grafana will be available at http://<your-server-ip>:3000. 
with Default username and password admin/admin**


## Integration

Now Let's intgerate Prometheus with Alertmanager and Grafana

1- **Edit the Prometheus configuration file To intgerate prometheus with Alertmanager:**

`sudo nano /etc/prometheus/prometheus.yml`

- Add the following under the `alerting` section:

```
alerting:
  alertmanagers:
    - static_configs:
        - targets:
          - "localhost:9093"
```

**then** 

`sudo systemctl restart prometheus`

2- **Configure Prometheus and Grafana**

**Add Prometheus as a data source in Grafana**:

    - Open Grafana (`http://<your-server-ip>:3000`).
    - Go to "Configuration" > "Data Sources".
    - Click "Add data source", select **Prometheus**, and enter `http://localhost:9090` as the URL.

. **Set up dashboards**:

    - You can import predefined dashboards 
      from Grafana's dashboard marketplace.


3- ****Install Node Exporter on Target Machines To scrape metrics:**

- Download: `wget https://github.com/prometheus/node_exporter/releases/download/v1.6.1/node_exporter-1.6.1.linux-amd64.tar.gz`

 ```
tar xvf node_exporter-1.6.1.linux-amd64.tar.gz
sudo cp node_exporter-1.6.1.linux-amd64/node_exporter /usr/local/bin/

```
- intgerate with SystemD:

`sudo nano /etc/systemd/system/node_exporter.service`

Add The Following Content:

```
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=root
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=default.target

```

Then Start The Service

```
sudo systemctl daemon-reload
sudo systemctl start node_exporter
sudo systemctl enable node_exporter
```


node_exporter is available via `http://localhost:9100/metrics`


**Integration between prometheus and node_exporter**:

`sudo nano /etc/prometheus/prometheus.yml`

Add a new scrape configuration for Node Exporter:
```
scrape_configs:
  - job_name: 'node_exporter'
    static_configs:
      - targets: ['<target-machine-ip>:9100']

```

Then

`sudo systemctl restart prometheus`

**Add Node Exporter Metrics to Grafana:**

Add Prometheus as a Data Source in Grafana (if not already added)

    1. Log into Grafana (`http://<grafana-ip>:3000`).
    2. Go to **Configuration** > **Data Sources**.
    3. Click **Add data source**, select **Prometheus**, and set the URL to `http://localhost:9090`.

#### Import a Node Exporter Dashboard

    1. In Grafana, go to **Dashboards** > **Manage** > **Import**.
    2. You can use a pre-built Node Exporter dashboard from Grafana's marketplace. Use dashboard node_exporter_Full
    3. Enter the ID in the **Import via Grafana.com** field and click **Load**.
    4. Select your Prometheus data source and click **Import**.

This will give you a ready-made dashboard for monitoring CPU, memory, disk, and other system metrics from the Node Exporter.

#### Configure Alertmanager for Slack notifications:

Generate Slack Webhook

- Create a Slack channel to get the alert manager notifications.
- Select the channel and go to “**Tools & Settings**” , then “**Workspace Settings**”
- Select “**Menu**” on the top-left corner



- Select “**Configure apps**” in the list appeared



- Search and find “**Incoming WebHooks**” from the Slack app directory and select Add to Slack to go to the webhook configuration page.


- In the new configuration tab, choose the channel you created before and click on Add Incoming WebHooks integration.



- Now, the webhook will be created. store them securely to configure them with Alert Manager.


#### Edit the Alertmanager configuration file (`/etc/alertmanager/alertmanager.yml`):

Replace the content with the following:

```
global:
  resolve_timeout: 5m

route:
  receiver: 'slack-notifications'

receivers:
  - name: 'slack-notifications'
    slack_configs:
      - api_url: 'https://hooks.slack.com/services/XXXXX/XXXXX/XXXXX'  # Replace with your Slack webhook URL
        channel: '#your-channel'  # Replace with the Slack channel name
        send_resolved: true
        title: "[ALERT] {{ .CommonAnnotations.summary }}"
        text: "{{ .CommonAnnotations.description }}"

```

Then:

`sudo systemctl restart alertmanager`

#### Create a Prometheus alert for high CPU usage

Edit the Prometheus configuration file (`/etc/prometheus/prometheus.yml`) and add the following alerting rule:

```
rule_files:
  - "/etc/prometheus/alert.rules.yml"
```
Then

`sudo nano /etc/prometheus/alert.rules.yml`

and Add the following Content:

```
groups:
  - name: CPU Usage Alerts
    rules:
    - alert: HighCPUUsage
      expr: 100 - (avg by(instance) (rate(node_cpu_seconds_total{mode="idle"}[1m])) * 100) > 50
      for: 1m
      labels:
        severity: critical
      annotations:
        summary: "High CPU usage on {{ $labels.instance }}"
        description: "CPU usage is above 50% (current value: {{ $value }}%) on {{ $labels.instance }}"

```

Then


`sudo systemctl restart prometheus`


## Testing

`sudo apt install stress`

`stress --cpu 4 --timeout 300`  # Simulates high CPU usage


**Wait for the message from Alertmanager on your slack channel**

Thanks


