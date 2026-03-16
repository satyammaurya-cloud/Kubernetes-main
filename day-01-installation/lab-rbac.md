## Lab: Allow 10 IAM Users to Access EKS Using One Dev Role

### Step 1 — Create IAM Users

Create 10 users.
Example:
```bash
dev1
dev2
dev3
dev4
dev5
dev6
dev7
dev8
dev9
dev10
```
AWS Console: IAM → Users → Create User

✅ Remark: These users are developers who need EKS access.

### Step 2 — Create IAM Group

Create group: ``` dev-group ```

Console: IAM → User Groups → Create Group

✅ Remark: We use group because managing permissions for 10 users individually is difficult.

### Step 3 — Add Users to Group

Add all users to the group.
```bash
dev1 → dev-group
dev2 → dev-group
dev3 → dev-group
dev4 → dev-group
dev5 → dev-group
dev6 → dev-group
dev7 → dev-group
dev8 → dev-group
dev9 → dev-group
dev10 → dev-group
```
Console: IAM → Groups → dev-group → Add users

✅ Remark: Now all users inherit permissions from the group.

### Step 4 — Create IAM Role

Create role: ``` dev-role ```

Console: IAM → Roles → Create Role

Attach policy example: ``` AmazonEKSClusterPolicy ``` or custom policy.

✅ Remark: Role defines what actions are allowed in AWS.

### Step 5 — Update Role Trust Policy

Edit Trust Relationship.

Example:
```bash
{
  "Effect": "Allow",
  "Principal": {
    "AWS": "arn:aws:iam::123456789012:root"
  },
  "Action": "sts:AssumeRole"
}
```
✅ Remark: This means:
``` This role trusts users from this AWS account. ```
But users still need ```sts:AssumeRole``` permission.

This means:
✔ The role trusts identities from this AWS account. But this alone is not enough.

Only users who have below this policy can assume the role. Only users inside ```dev-group``` get this permission.

### Step 6 — Create AssumeRole Policy

Create policy:
```bash
{
  "Effect": "Allow",
  "Action": "sts:AssumeRole",
  "Resource": "arn:aws:iam::123456789012:role/dev-role"
}
```
Attach this policy to: ``` dev-group ``

Console: IAM → Groups → dev-group → Attach policy

✅ Remark: This allows group users to assume dev-role.

### Step 7 — Map Role in EKS

Edit aws-auth ConfigMap.
```bash
kubectl edit configmap aws-auth -n kube-system
```
Add role mapping.
```
mapRoles: |
  - rolearn: arn:aws:iam::123456789012:role/dev-role
    username: developer
    groups:
      - developer
```
✅ Remark: This step maps AWS IAM role → Kubernetes identity.

### Step 8 — Create Kubernetes RBAC

Example RoleBinding.
```bash
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: developer-binding
  namespace: default

subjects:
- kind: Group
  name: developer
  apiGroup: rbac.authorization.k8s.io

roleRef:
  kind: ClusterRole
  name: edit
  apiGroup: rbac.authorization.k8s.io
```
✅ Remark: RBAC controls what developers can do inside Kubernetes.

Final Flow:
```bash
10 IAM Users
     ↓
IAM Group (dev-group)
     ↓
sts:AssumeRole permission
     ↓
Assume dev-role
     ↓
aws-auth mapping
     ↓
Kubernetes RBAC
     ↓
EKS Access
```
# Key Concepts From This Lab

| Component | Purpose |
|---|---|
| IAM Users | Developers |
| IAM Group | Manage permissions easily |
| IAM Role | AWS permissions |
| Trust Policy | Who can assume role |
| sts:AssumeRole policy | Allows users to assume role |
| aws-auth ConfigMap | AWS → Kubernetes authentication |
| RBAC | Kubernetes authorization |
