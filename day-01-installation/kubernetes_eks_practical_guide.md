# Kubernetes & EKS Practical Guide

**Purpose:** DevOps learning, interview preparation, and practical
Kubernetes reference

------------------------------------------------------------------------

# Table of Contents

1.  Introduction to Kubernetes\
2.  Kubernetes Architecture\
3.  EKS Setup\
4.  Kubernetes Services\
5.  Kubernetes Scheduling\
6.  Kubernetes Storage\
7.  Helm\
8.  Monitoring\
9.  Logging\
10. Security\
11. Kubernetes Workloads\
12. ArgoCD\
13. References

------------------------------------------------------------------------

# 1. Introduction to Kubernetes

**Kubernetes** is a container orchestration system originally developed
by **Google** to manage containerized applications at scale.

Kubernetes manages containers across a **cluster of machines**, ensuring
applications run reliably even when nodes fail or demand increases.

### Kubernetes helps to

-   Deploy applications
-   Scale containers automatically
-   Manage container lifecycle
-   Provide networking and storage

A Kubernetes cluster consists of:

-   **Control Plane (Master Node)** -- manages the cluster
-   **Worker Nodes** -- run application containers

------------------------------------------------------------------------

# 2. Kubernetes Architecture

A Kubernetes cluster is divided into two main components:

-   **Control Plane**
-   **Worker Nodes**

The control plane manages the overall cluster, while worker nodes run
the actual applications.

## Control Plane Components

### API Server

Handles API requests and communicates with cluster components.

### Scheduler

Assigns Pods to nodes based on CPU, memory, labels, and resource
availability.

### ETCD

Distributed key‑value database storing cluster configuration and state.

### Controller Manager

Runs controllers that ensure the desired state of the cluster.

------------------------------------------------------------------------

## Worker Node Components

### Kubelet

Agent that communicates with the control plane and manages Pods.

### Kube Proxy

Handles network communication between Pods and Services.

### Container Runtime

Runs containers on nodes (containerd, CRI‑O, etc).

### Nodes

Physical or virtual machines that run containers.

### Pods

Smallest deployable unit in Kubernetes.

------------------------------------------------------------------------

# 3. EKS Setup

Amazon **EKS (Elastic Kubernetes Service)** is a managed Kubernetes
service provided by AWS.

Example command:

    eksctl create cluster --name my-cluster --region ap-south-1 --node-type t2.small

Update kubeconfig:

    aws eks update-kubeconfig --region ap-south-1 --name my-cluster

Verify cluster:

    kubectl get nodes

------------------------------------------------------------------------

# 4. Kubernetes Services

A **Service** exposes an application running inside Pods.

Types:

-   ClusterIP
-   NodePort
-   LoadBalancer
-   Headless Service

------------------------------------------------------------------------

# 5. Kubernetes Scheduling

Scheduling decides **which node will run a Pod**.

## Node Selector

    kubectl label nodes node1 size=large

Pod YAML:

    nodeSelector:
      size: large

## Node Affinity

-   **Required** -- Pod runs only if rule matches
-   **Preferred** -- Scheduler prefers matching nodes but may run
    elsewhere

## Taints and Tolerations

Used to control which Pods can run on specific nodes.

------------------------------------------------------------------------

# 6. Kubernetes Storage

Volumes allow containers to **store persistent data**.

Storage types:

-   HostPath
-   AWS EBS
-   Dynamic provisioning via StorageClass

------------------------------------------------------------------------

# 7. Helm

**Helm** is the package manager for Kubernetes.

Example:

    helm install hotstar-v1 hotstar-chart

Helm charts bundle multiple Kubernetes YAML resources.

------------------------------------------------------------------------

# 8. Monitoring

Monitoring tracks cluster health.

Common tools:

-   Prometheus
-   Grafana
-   Metrics Server

## Kubernetes Probes

-   **Liveness Probe** -- checks if container is alive
-   **Readiness Probe** -- checks if container can receive traffic
-   **Startup Probe** -- checks if application started successfully

------------------------------------------------------------------------

# 9. Logging

EFK stack for centralized logging:

-   Elasticsearch -- log storage
-   Fluent Bit -- log collection
-   Kibana -- log visualization

------------------------------------------------------------------------

# 10. Security

Security mechanisms include:

-   RBAC
-   Service Accounts
-   IAM Roles for Service Accounts (IRSA)

------------------------------------------------------------------------

# 11. Kubernetes Workloads

Workloads define how applications run.

Common workloads:

-   Deployments
-   StatefulSets
-   DaemonSets

### Deployment Features

-   Automatic Scaling
-   Rolling Updates
-   Rollbacks
-   Self‑healing Pods

### StatefulSets

Used for stateful applications requiring persistent storage.

### DaemonSet

Ensures one Pod runs on every node.

------------------------------------------------------------------------

# 12. ArgoCD

**ArgoCD** is a GitOps continuous delivery tool for Kubernetes that
syncs clusters with Git repositories.

------------------------------------------------------------------------

# 13. References

Helm Charts Guide\
https://medium.com/@veerababu.narni232/writing-your-first-helm-chart-for-hello-world-40c05fa4ac5a

Prometheus Monitoring\
https://medium.com/@veerababu.narni232/deployment-of-prometheus-and-grafana-using-helm-in-eks-cluster-22caee18a872

ArgoCD Guide\
https://medium.com/@veerababu.narni232/a-complete-overview-of-argocd-with-a-practical-example-f4a9a8488cf9

EFK Stack Guide\
https://medium.com/@veerababu.narni232/setting-up-the-efk-stackwhat-is-efk-stack-7944fb4e56f0
