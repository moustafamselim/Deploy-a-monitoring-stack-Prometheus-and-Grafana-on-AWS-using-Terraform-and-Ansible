### Install and Configure Monitoring Stack as Service [Prometheus, Grafana, Alert Manager, and Slack]
- Create Ansible Playbook to install prometheus, node exporter, grafana
- Lab Promtheus, grafana, alert manager, slack intgeration 
- Any infrastructure will be deployed on AWS, please provide Terraform Code
- Show off your work by pushing it to Github and write a well-explained Readme file

## <ins>Contents
- [Monitoring Tools](#monitoring-tools )
- [AWS Configuration](#aws-configuration)
- [Ansible Automation](#ansible-automation)
- [Node Exporter](#node-exporter)
- [Integration](#integration)
- [Slack Output](#slack-output)
--------------------
## Monitoring Tools
**Prometheus, Alert Manager , Grafana**
- **<ins>Prometheus** : open-source systems monitoring and alerting
  Time-series database: Stores metrics as time-series data
  **Expose Port 9090**
- **<ins>Alert Manager** :is a component of the Prometheus 
  ecosystem that handles alerts sent by Prometheus.
  **Expose Port 9093**
- **<ins>Grafana** :is an open-source platform for monitoring and
   observability. It allows you to visualize, analyze, and explore  metrics from various data sources, including Prometheus.
   **Expose Port 3000**
---------------
## Node Exporter
Node Exporter is a Prometheus exporter that collects system-level metrics from Linux/Unix systems. It exposes these metrics in a format that Prometheus can scrape, making it an essential tool for monitoring the health and performance of your infrastructure.

**System Metrics Collection:**
```
CPU usage
Memory usage
Disk I/O
Network statistics
System load
File system usage
Hardware and temperature metrics (if supported)
```
**Exposes 9100/metrics**

----------------------------------------------------------------------
## AWS Configuration
#### Using Terraform (IAC)
    main.tf
    provider.tf
    var.tf
    backend.tf
    outputs.tf
 **IN ( us-east-1)**
  - Create VPC & Cidr Block
  - Create Tow Ec2 t2.micro (Control & Target)inside New Vpc
  - Public Subnet (Route_table Allow All)
  - key Pair
  - Create all required variables
  - Share the state file on AWS_S3 
  - <ins>Show in the output file
      - vpc
      - vpc_cidr 
      - Tow instance (Control & Target)
      - Key Pair
      - ami 
      - Public Subnet (Route_table Allow All)

### Prerequisites
- AWS Account with IAM permissions
- AWS CLI installed and configured

### Access Key CLI AWS
  **Add Secret access key & Access key**

   ```bash
   aws configure
 ```
-----
## Ansible Automation

#### Using Ansible Playbook
     install_monitoring.yaml
     node_exporter.yaml
     inventory.yaml
Create files ( playbook & inventory)
Playbook to (Install Monitoring Tools ) in Ec2 Control
Playbook to (Install Node Exporter) in Ec2 Target
Inventory to (Hosts - Control & Target)

---------------
## Integration
#### Edit the Prometheus configuration file To intgerate prometheus with Alertmanager

    sudo nano /etc/prometheus/prometheus.yml

 **Add the following under the `alerting` section**:


    alerting:
      alertmanagers:
        - static_configs:
            - targets:
              - "localhost:9093"

**Restart**

    sudo systemctl restart prometheus



**Integration between prometheus and node_exporter**:

**Add a new `scrape` configuration for `Node Exporter`**:

    scrape_configs:
      - job_name: 'node_exporter'
        static_configs:
          - targets: ['<target-machine-ip>:9100']
  
  **Restart**

    sudo systemctl restart prometheus


#### Create a Prometheus alert for high CPU usage

    sudo nano /etc/prometheus/prometheus.yml

**add the following alerting rule**:

```
rule_files:
  - "/etc/prometheus/alert.rules.yml"
```
**Restart**

    sudo systemctl restart prometheus


#### Create a Prometheus alert for high CPU usage


    sudo nano /etc/prometheus/alert.rules.yml

**Add**

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

**Restart**

    sudo systemctl restart prometheus

---

**Configure Alertmanager for Slack notifications:**

**Generate Slack Webhook**

    Create a Slack channel to get the alert manager notifications.

    Select the channel and go to “Tools & Settings” , then “Workspace Settings”

    Select “Menu” on the top-left corner

    Select “Configure apps” in the list appeared

    Search and find “Incoming WebHooks” from the Slack app directory and select Add to Slack to go to the webhook configuration page.

    In the new configuration tab, choose the channel you created before and click on Add Incoming WebHooks integration.

    Now, the webhook will be created. store them securely to configure them with Alert Manager.

**Edit the Alertmanager configuration file (/etc/alertmanager/alertmanager.yml):**

**Replace the content with the following:**

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

**Then:**

    sudo systemctl restart alertmanager
------
### Slack Output

![Slack](https://github.com/moustafamselim/Deploy-a-monitoring-stack-Prometheus-and-Grafana-on-AWS-using-Terraform-and-Ansible/blob/8f23c449f113f270a5d2f22daa4b4cda26adecf6/image/output.png)

