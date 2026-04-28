# Deployment of Prometheus and Grafana using Helm in EKS Cluster

This repository contains documentation for setting up a production-ready monitoring stack on Amazon EKS using Helm, Grafana for visualization, and PagerDuty for incident response.

<img width="1000" height="500" alt="image" src="https://github.com/user-attachments/assets/0dbf77bb-7eeb-4efb-ac61-1defcd8fabef" />


## 📌 Overview
- **Prometheus:** Collects and stores metrics as time-series data via HTTP pull.
- **Grafana:** Visualizes metrics through customizable dashboards.
- **Alertmanager:** Handles alerts and routes them to external systems.
- **PagerDuty:** Receives alerts for on-call notification and incident management.

---

## 🛠️ Prerequisites
- **EC2 Instance:** `t2.micro` (Management Node).
- **Amazon EKS Cluster:** Configured and accessible via `kubectl`.
- **Helm:** Kubernetes package manager installed.
- **Security Groups:** Port `80` (or the specific LoadBalancer ports) open to your IP.

- **Why use helm? -** Helm is a package manager for Kubernetes. Helm simplifies the installation of all components in one command. install using helm is recommended as you will not be missing any configuration steps and very efficient.

---

## 🚀 Step 1: Tool Installation

If **Helm** is not installed on your management instance, execute the following:
```bash
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
```

---

## 📦 Step 2: Deploy Monitoring Stack

1. **Add Helm Repositories:**

   ```sh
   # We need to add the Helm Stable Charts for your local client.
   
   helm repo add stable https://charts.helm.sh/stable

   # Add Prometheus Helm repo
   
   helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
   helm repo update
   ```

2. **Create Namespace:**
   ```bash
   kubectl create namespace prometheus
   ```

3. **Install the Stack:**
   The `kube-prometheus-stack` includes Prometheus, Grafana, and Alertmanager by default.
   ```bash
   helm install stable prometheus-community/kube-prometheus-stack -n prometheus
   ```

4. **Verify Deployment:**
   ```bash
   kubectl get pods -n prometheus
   kubectl get svc -n prometheus
   ```

---

## 🌐 Step 3: Exposing the Services

To access the UIs from a browser, change the service type to `LoadBalancer`.

1. **Expose Prometheus:**

    - To clarify, the Prometheus server itself is actually running inside your EKS cluster as a Pod, not directly on the EC2 operating system as a standard service.
    - Then modiy the worker node SG and allow 0.0.0.0/0 and `kubectl get node -o wide` and copy external IP and access it with 'http://node-ip:nodeport'

   ```bash
   kubectl edit svc stable-kube-prometheus-sta-prometheus -n prometheus
   # Change 'type: ClusterIP' to 'type: LoadBalancer/NodePort'
   ```

2. **Expose Grafana:**
   ```bash
   kubectl edit svc stable-grafana -n prometheus
   # Change 'type: ClusterIP' to 'type: LoadBalancer'
   ```

3. **Retrieve URLs:**
   Run `kubectl get svc -n prometheus` and copy the **External-IP** for both services.

---

## 🔐 Step 4: Accessing Grafana

1. **Retrieve Admin Password:**
   ```bash
   kubectl get secret --namespace prometheus stable-grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
   ```
2. **Login:** Use username `admin` and the password retrieved above at the Grafana LoadBalancer URL.
3. **Import Dashboard:** 
   - Navigate to **Dashboards > Import**.
   - Use standard Prometheus templates (e.g., ID `15661`) to visualize EKS CPU, RAM, and Pod metrics.

---

## 🔔 Step 5: Configuring PagerDuty Alerts

### 1. In PagerDuty
- Go to the PagerDuty website: https://www.pagerduty.com/. 
- Log in to your PagerDuty account using your credentials.
- Navigate to **Services > New Service**.
- Provide a name and select **Integration Type**: `Events API v2`.
- Copy the generated **Integration Key**.

### 2. In Grafana (Connect PagerDuty)
- **Add Contact Point:** Go to `Alerting > Contact Point`. Select **PagerDuty** and paste your Integration Key.
- **Create Alert Rule:**
  - Go to Alerting > Alert Rules. -> + Create Alert Rule.
  - **Metric:** `100 - (avg by (instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)`
  - **Threshold:** Set condition to `Above 90`.
  - **Notification:** Assign the PagerDuty Contact Point.

---

## 📋 Summary of Commands


| Action | Command |
| :--- | :--- |
| Install Stack | `helm install stable prometheus-community/kube-prometheus-stack -n prometheus` |
| View Pods | `kubectl get pods -n prometheus` |
| View Services | `kubectl get svc -n prometheus` |
| Edit Service | `kubectl edit svc <service-name> -n prometheus` |
| Get Password | `[kubectl get secret --namespace prometheus stable-grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo]` |

---

### 📊 Recommended Grafana Dashboards


| Dashboard Name | ID | Primary Use Case |
| :--- | :--- | :--- |
| **Kubernetes All-in-One** | **15661** | The classic general overview for pods and cluster health. |
| **Node Exporter Full** | **1860** | Hardware-level stats (CPU, RAM, Disk) for the EC2 nodes. |
| **Kubernetes Cluster** | **315** | High-level cluster health and capacity planning. |
| **Kubernetes Global View** | **15760** | Resource usage filtered by **Namespace** and Workload. |
| **Deployment/Pod Health** | **8588** | Deep dive into **Restarts**, **Crashes**, and Pod errors. |
| **Kubernetes Networking** | **15666** | Monitoring bandwidth, packet rates, and network errors. |

#### 💡 How to Import
1. In Grafana, go to **Dashboards** > **Import**.
2. Enter the **ID** from the table above.
3. Select your **Prometheus** data source and click **Import**.
