# Helm Charts Guide

## What is Helm?

Helm is a tool that automates the **creation, packaging, configuration, and deployment of Kubernetes applications** by combining multiple Kubernetes configuration files into a single reusable package called a **Helm Chart**.

---

# Install Helm

Official Helm releases:

https://github.com/helm/helm/releases

### Installation Steps

```bash
wget https://get.helm.sh/helm-v3.14.0-linux-amd64.tar.gz
tar -zxvf helm-v3.14.0-linux-amd64.tar.gz
mv linux-amd64/helm /usr/local/bin/helm
chmod 777 /usr/local/bin/helm
```
Verify installation:
```bash
helm version
```
---

# Create a Helm Chart

Create a sample Helm chart:

```bash
helm create hotstar-chart
```

This command generates a Helm chart template structure.

---

# Helm Chart Structure

```
hotstar-chart
├── charts
├── Chart.yaml
├── templates
│   ├── deployment.yaml
│   ├── _helpers.tpl
│   ├── hpa.yaml
│   ├── ingress.yaml
│   ├── NOTES.txt
│   ├── serviceaccount.yaml
│   ├── service.yaml
│   └── tests
│       └── test-connection.yaml
└── values.yaml
```

---

# Important Files

| File | Purpose |
|-----|------|
| Chart.yaml | Chart metadata |
| values.yaml | Default configuration values |
| templates/ | Kubernetes manifest templates |
| charts/ | Dependency charts |

---

# Install Helm Chart

```bash
helm install <RELEASE_NAME> <CHART_NAME>
```

Example:

```bash
helm install hotstar-v1 hotstar-chart
```

---

# List Helm Releases

```bash
helm list -a
```

Shows all Helm releases in the cluster.

---

# Upgrade Helm Chart

```bash
helm upgrade firstproject helloworld
```

Used to update an existing Helm release.

---

# Delete Helm Release

```bash
helm delete <RELEASE_NAME>
```

Example:

```bash
helm delete firstproject
```

---

# Helm Workflow

```
Helm Chart
     ↓
helm install
     ↓
Kubernetes resources created
(Deployment / Service / Pods)
```

---

# Reference

For more details refer to this article:

[Writing Your First Helm Chart for Hello World](https://medium.com/@veerababu.narni232/writing-your-first-helm-chart-for-hello-world-40c05fa4ac5a)
