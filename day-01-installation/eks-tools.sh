#!/bin/bash

# --- Configuration & Error Handling ---
set -e          # Exit immediately if a command fails
set -u          # Treat unset variables as errors
set -o pipefail # Catch errors in piped commands

# Define variables for easier adjustments
CLUSTER_NAME="dev-cluster"
REGION="us-east-1"
NODE_GROUP="dev-workers"
NODE_TYPE="t2.small"

echo "--- Installing kubectl ---"
# Download the latest stable release of kubectl
K8S_VERSION=$(curl -L -s https://dl.k8s.io/release/stable.txt)
curl -LO "https://dl.k8s.io/release/${K8S_VERSION}/bin/linux/amd64/kubectl"

# Install to /usr/local/bin
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/
kubectl version --client

echo "--- Installing eksctl ---"
# Download and extract the latest eksctl binary
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin
eksctl version

echo "--- Creating EKS Cluster (Approx. 15-20 minutes) ---"
# Create the cluster with a managed nodegroup
# NOTE: us-east-1 sometimes requires specific zones (e.g., --zones=us-east-1a,us-east-1b) 
eksctl create cluster --name "$CLUSTER_NAME" \
  --region "$REGION" \
  --nodegroup-name "$NODE_GROUP" \
  --node-type "$NODE_TYPE" \
  --nodes 2 \
  --managed

echo "--- Cluster Setup Complete ---"
kubectl get nodes
