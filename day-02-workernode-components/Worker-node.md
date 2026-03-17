# Node Group (EKS)

A Node Group is a group of EC2 worker nodes in an EKS cluster.

Node Group contains multiple worker nodes and manages the Auto Scaling Group (ASG) and the IAM role permissions assigned to those worker nodes.

It automatically manages:

#### 1. Worker Nodes (EC2 instances)

#### 2. Auto Scaling Group (ASG) – to scale nodes up/down

#### 3. Launch Template / Configuration – instance type, AMI, etc.

#### 4. IAM Role for Worker Nodes – permissions for nodes to interact with AWS services.
---
One-Line Definition (Best for Interviews)

Node Group = Logical group of worker nodes that are managed by an Auto Scaling Group and share the same IAM role and configuration.

Simple Flow
```yaml
EKS Cluster
     │
     └── Node Group
            │
            ├── Worker Node (EC2)
            ├── Worker Node (EC2)
            ├── Worker Node (EC2)
            │
            ├── Auto Scaling Group
            └── Node IAM Role
```
Extra Important Point (for DevOps Interviews)

- One Node Group → One IAM Role
- One Node Group → One ASG

Multiple Node Groups can exist in one EKS Cluster

Example:
```yaml
EKS Cluster
 ├── NodeGroup-1 (t3.medium)
 ├── NodeGroup-2 (t3.large)
 └── NodeGroup-3 (GPU nodes)
```
