# axol-api

To set up the Ansible repository and deploy axol-flavor MinIO, follow these steps:

## Prerequisites

- **Install Ansible**:

  ```bash
  pip install ansible
  ```

- **SSH Access**: Ensure you have SSH access to the target servers.

### Configuring Ansible

- **Clone the Repository**:

  ```bash
  git clone https://github.com/Hydepwns/axol-api
  cd axol-api
  ```

- **Edit the Inventory**: Update the `ansible/inventory.ini` file with your target servers.

### Running the Playbook

- **Execute the Ansible Playbook**: Run the following command to deploy MinIO on the target servers:

  ```bash
  ansible-playbook -i ansible/inventory.ini ansible/deploy_minio.yml
  ```

### Setting Up Monitoring

- **Install Prometheus**: Deploy Prometheus on the target servers using the Ansible playbook:

  ```bash
  ansible-playbook -i ansible/inventory.ini ansible/roles/prometheus/tasks/main.yml
  ```

- **Install Grafana**: Deploy Grafana on the target servers using the Ansible playbook:

  ```bash
  ansible-playbook -i ansible/inventory.ini ansible/roles/grafana/tasks/main.yml
  ```

- **Configure Prometheus**: Update your Prometheus configuration to scrape metrics from the target servers. Add the following job to your `prometheus.yml` configuration file:

  ```yaml
  scrape_configs:
    - job_name: 'minio'
      static_configs:
        - targets: ['<target_server_1>:9100', '<target_server_2>:9100']
  ```

- **Restart Prometheus**: Apply new configuration by restarting Prometheus service:

  ```bash
  sudo systemctl restart prometheus
  ```

- **Verify Monitoring**: Access Prometheus web ui to ensure that the target servers are being scraped:

  ```bash
  http://<prometheus_server>:9090
  ```

- **Access Grafana**: Open the Grafana web interface to visualize the metrics:

  ```bash
  http://<grafana_server>:3000
  ```
