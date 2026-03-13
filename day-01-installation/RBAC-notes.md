# Kubernetes RBAC Process (EKS)

RBAC (Role-Based Access Control) controls who can perform what actions in a Kubernetes cluster.


- **Roles / ClusterRoles** → Define what actions are allowed
- **RoleBindings / ClusterRoleBindings** → Define who can perform those actions

In **EKS**, AWS IAM users/roles are mapped to Kubernetes users through the **aws-auth ConfigMap** in the **kube-system namespace**.

After mapping, RBAC permissions can be assigned.

---

## RBAC Components

| Component | Meaning | Example |
|---|---|---|
| Role | Defines actions allowed inside one namespace | Read pods in dev namespace |
| ClusterRole | Defines actions allowed cluster-wide | Read pods in all namespaces |
| RoleBinding | Connects a Role to a User/Group | Give developer pod access in dev |
| ClusterRoleBinding | Connects a ClusterRole to User/Group cluster-wide | Give admin access to entire cluster |

---

## Role vs ClusterRole

| Feature | Role | ClusterRole |
|---|---|---|
| Scope | Works inside one namespace | Works across entire cluster |
| Manage namespaced resources | ✅ Yes | ✅ Yes |
| Manage cluster resources (nodes, namespaces) | ❌ No | ✅ Yes |
| Binding type | RoleBinding | ClusterRoleBinding |
| Example | Dev access to pods in dev namespace | Admin access to all namespaces |

---

## RBAC Process in EKS

### Step 1
Create IAM Role / User (AWS Level Authentication) with minimal policy: ex -> AmazonEKSClusterPolicy

### Step 2
Configure AWS CLI profile.
```bash
aws configure --profile <developer-user-1>
```
Now provide IAM user: AccessKey, SecretKey and Region
### Step 3
Create a Kubernetes Role with limited permissions.
### Step 4
Create a RoleBinding to bind the role to a group.
Now bind Role → developer group.
### Step 5
Now map the IAM user/role ARN to aws-auth ConfigMap file.
```bash
kubectl edit cm aws-auth -n kube-system
```
Add the user mapping:
```yaml
mapUsers:
- userarn: arn:aws:iam::123456789012:user/developer-user-1
  username: developer-user
  groups:
  - developer
```
Verify the update:
```bash
kubectl get configmap aws-auth -n kube-system -o yaml
```
You should see the developer group mapping.
### Step 6
After updating aws-auth: Update kubeconfig.

It switchs CLI Profile:
```bash
aws eks update-kubeconfig --region us-east-1 --name my-eks-cluster --profile developer-user-1
```
This updates: ~/.kube/config
- Now developer IAM user can use kubectl commands. ```bash kubectl get pods ```

Verify Identity:
```bash
kubectl auth whoami

Output similar to:

Username: developer-user
Groups: developer
```
---
## Kubernetes Role

A Role defines permissions (what actions can be performed) within a specific namespace.
It cannot provide cluster-wide access; for that, use ClusterRole.

### Example: Role
```yaml
kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  namespace: default
  name: developer-role

rules:
- apiGroups: [""]
  resources: ["configmaps"]
  verbs: ["get","list"]

- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get","list"]

- apiGroups: ["apps"]
  resources: ["deployments"]
  verbs: ["get","list"]
```
---
## RoleBinding 

A RoleBinding assigns a Role to a specific user, group.
It allows users to perform the actions specified in the Role within a namespace.

Role Binding to map role and group
### Example: RoleBinding
```yaml
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: read-pods
  namespace: default

subjects:
- kind: Group
  name: developer
  apiGroup: rbac.authorization.k8s.io

roleRef:
  kind: Role
  name: developer-role
  apiGroup: rbac.authorization.k8s.io
```
---
## ------------------Cluster role and cluster role binding -------------- #
### Example: ClusterRole (Full Permissions)

```yaml
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: cluster-admin-custom
rules:
- apiGroups: ["*"]
  resources: ["*"]
  verbs: ["*"]
```
This gives full cluster access.

### Example: ClusterRoleBinding 

```yaml
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: cluster-admin-custom-binding

subjects:
- kind: Group
  name: admin-team
  apiGroup: rbac.authorization.k8s.io

roleRef:
  kind: ClusterRole
  name: cluster-admin-custom
  apiGroup: rbac.authorization.k8s.io
```

---

# User with admin access (Optional)

To give full admin access: Below for full permissions groups -system:master
```yaml
mapUsers: |
  - userarn: arn:aws:iam::381491944316:user/user-1
    username: user-1
    groups:
      - system:masters
```
############# Below block need to be added aws-auth ################3                
```yaml
mapRoles: |
    - groups:
      - system:bootstrappers
      - system:nodes
      rolearn: arn:aws:iam::545009827818:role/eksctl-naresh-nodegroup-ng-2b5f9fe-NodeInstanceRole-Fifi7BsDcajz
      username: system:node:{{EC2PrivateDNSName}}
 mapUsers: |
    - userarn: arn:aws:iam::545009827818:user/user-1
      username: user-1
      groups:
        - system:masters
```

# Note:
In Kubernetes, system:masters is a built-in cluster-admin group that provides full administrative access to the cluster.

---

# Update kubeconfig

After updating aws-auth:

```bash
aws eks update-kubeconfig --name test --profile devops
```

Default cluster creator:

```bash
aws eks update-kubeconfig --name siva
```

Cluster creator automatically gets admin permissions.

---

# Useful Commands

```bash
kubectl get rb
kubectl get rolebinding
kubectl api-resources
kubectl get cm -n kube-system
```

---

# Service Accounts (For Pods)

ServiceAccounts allow pods to interact with Kubernetes API.


---

## Step 1: Create ServiceAccount

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: my-service-account
  namespace: default
```

---

## Step 2: Create Role

```yaml
kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: pod-reader
  namespace: default

rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get","list"]
```

---

## Step 3: RoleBinding

```yaml
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: pod-reader-binding
  namespace: default

subjects:
- kind: ServiceAccount
  name: my-service-account
  namespace: default

roleRef:
  kind: Role
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io
```

---

## Step 4: Use ServiceAccount in Pod

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: myapp

spec:
  serviceAccountName: my-service-account

  containers:
  - name: nginx-container
    image: nginx
```

---

# Verify Permissions

Enter pod:

```bash
kubectl exec -it myapp -- /bin/bash
```

Check:

```bash
kubectl get pods
```

It works because the ServiceAccount has pod-reader role.

---

# Pod Access to AWS Services (IRSA)

Pods can access AWS services using **IAM Roles for Service Accounts (IRSA)**.

Example: Pod accessing S3

---

## Step 1 Create IAM Policy

```json
{
 "Version": "2012-10-17",
 "Statement": [
  {
   "Effect": "Allow",
   "Action": [
    "s3:ListAllMyBuckets",
    "s3:ListBucket"
   ],
   "Resource": "*"
  }
 ]
}
```

---

## Step 2 Create Policy

```bash
aws iam create-policy \
--policy-name EKS_S3_Access_Policy \
--policy-document file://s3-access-policy.json
```

---

## Step 3 Enable OIDC

```bash
eksctl utils associate-iam-oidc-provider \
--region ap-south-1 \
--cluster dev-cluster \
--approve
```

---

## Step 4 Create IAM Service Account

```bash
eksctl create iamserviceaccount \
--name s3-access-sa \
--namespace default \
--cluster dev-cluster \
--attach-policy-arn arn:aws:iam::ACCOUNT:policy/EKS_S3_Access_Policy \
--approve
```

---

## Step 5 Create Pod

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: aws-cli-pod

spec:
  serviceAccountName: s3-access-sa

  containers:
  - name: aws-cli
    image: amazonlinux:2
    command: ["sleep","3600"]
```

---

## Step 6 Install AWS CLI inside pod

```bash
yum install -y unzip curl

curl https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip

unzip awscliv2.zip

./aws/install
```

---

## Step 7 Test S3 Access

```bash
aws s3 ls
```

If permissions are correct, S3 buckets will be listed.

---

# Final Quick Summary

| Component | Purpose |
|---|---|
| IAM User | AWS identity |
| aws-auth ConfigMap | Maps IAM → Kubernetes |
| Role | Namespace permissions |
| RoleBinding | Attach role to user/group |
| ClusterRole | Cluster-wide permissions |
| ClusterRoleBinding | Bind cluster role |
| ServiceAccount | Identity for pods |
| IRSA | Pod access to AWS services |
