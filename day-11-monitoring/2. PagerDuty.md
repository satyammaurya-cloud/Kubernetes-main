# 🚀 Grafana & PagerDuty Integration Guide

This repository contains the documentation and steps required to link **Grafana Alerting** with **PagerDuty** for automated incident response.

<img width="1050" height="553" alt="image" src="https://github.com/user-attachments/assets/66e010ab-4ac2-4186-914d-89b72af6620a" />

---

## 1. 🏗️ PagerDuty Account Setup
Before connecting to Grafana, you must configure your PagerDuty environment.
#### Account Creation
1.  **Sign Up:** Visit [PagerDuty Sign Up](https://pagerduty.com).
2.  **Domain Requirement:** Use a **business email domain** (e.g., `@yourcompany.com`). PagerDuty often restricts free trials for generic domains like `@gmail.com`.
3.  **Regional Data Center:** Choose between **US** or **EU** based on your data residency requirements.

---

## 2. 🔌 Service & Integration Key
You need a specific service in PagerDuty to receive Grafana alerts.

1.  **Create Service:** Go to **Services** > **Service Directory** > **+ New Service**.
2.  **Name:** Use a descriptive name like `Infrastructure-Monitoring`.
3.  **Assign Policy:** Select an **Escalation Policy** (who to page first).
4.  **Integrations:** 
    *   Search for **"Events API V2"**.
    *   **Crucial:** Do *not* use "Grafana" if it points to a legacy webhook; **Events API V2** is the modern standard for Grafana Contact Points.
5.  **Copy Key:** Once created, copy the **Integration Key** from the service's "Integrations" tab.

---

## 3. 📊 Grafana Configuration
Apply the integration key to your Grafana instance.

### A. Create Contact Point
1.  Navigate to **Alerting** > **Contact points**.
2.  Click **+ Add contact point**.
3.  **Integration:** Select `PagerDuty`.
4.  **Integration Key:** Paste the key copied from PagerDuty.
5.  **Test:** Click **Test** and verify a "Triggered" incident appears in PagerDuty.

### B. Setup Alert Rule (Example: High CPU)
1.  **Enter alert rule name**: High-CPU-Alert-Test
1.  **Add PromQL for Metric:** `100 - (avg by (instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)`
2.  **Threshold:** Set to `80` (fires if CPU > 80%). `#add 2-3% to check it`
3.  **Folder/Group:** Create a folder (e.g., `Infra-Servers`) and an evaluation group (e.g., `1m`).
4.  **Notification:** Select the `PagerDuty` contact point.

---
## 4. ✅ Verification & Firing Status
After saving the rule, follow these steps to verify the integration is live:

1.  **Wait for Evaluation:** Allow at least **1 minute** (or your defined evaluation interval) for the rule to process.
2.  **Check Alert Manager:** Navigate to **Alerting > Alert rules**. You will see the state change to **`Firing`** (in red) if the threshold is breached.
3.  **PagerDuty Confirmation:** Log into PagerDuty. You will see a new **Triggered Incident** corresponding to the alert.
4.  **Auto-Resolution:** Once the metric returns to normal, Grafana sends a "Resolve" event, and the PagerDuty incident will **automatically close**.


