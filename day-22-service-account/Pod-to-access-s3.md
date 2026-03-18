# Kubernetes EKS – Service Account + IRSA (Pod → S3 Access)

## Overview
This lab demonstrates how a **Kubernetes Pod in Amazon EKS** can securely access **AWS S3** using **IAM Roles for Service Accounts (IRSA)** instead of giving permissions to the entire worker node.

Using IRSA improves security because **only the specific pod gets AWS permission**, not every pod on the node.

---

# Architecture Flow

```
IAM Policy
     ↓
IAM Role (IRSA)
     ↓
ServiceAccount
     ↓
Pod
     ↓
S3 Access
```

---

# Step 1 — Enable OIDC Provider for EKS

Enable the OIDC identity provider for your EKS cluster.

```bash
eksctl utils associate-iam-oidc-provider --cluster project-eks --region us-east-1 --approve
```

**Remark:**  This allows pods inside the EKS cluster to access AWS services using IAM roles.

Creating **Open ID Connect** to connect node inside resource (pod) to outside eks cluster aws resources if node group IAM role and Access/Secrest key permission is there or not.

---

# Step 2 — Create JSON Permission File for S3 Access

Create a JSON file for S3 access.

### File: `s3-access-policy.json`

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

Create the IAM policy:

```bash
aws iam create-policy \
--policy-name EKS_S3_Access_Policy \
--policy-document file://s3-access-policy.json
```

Example output:

```
arn:aws:iam::ACCOUNT-ID:policy/EKS_S3_Access_Policy
```

**Remark:**  Defines **what AWS S3 permissions the pod will get**.

---

# Step 3 — Create IAM Role + Kubernetes Service Account (IRSA)

Create the IAM role and service account together using `eksctl`.

```bash
eksctl create iamserviceaccount \
--name s3-access-svc \
--namespace default \
--cluster project-eks \
--attach-policy-arn arn:aws:iam::ACCOUNT-ID:policy/EKS_S3_Access_Policy \
--approve
```

### What this command does automatically

- Creates an **IAM Role**
- Attaches the **S3 policy**
- Creates a **Kubernetes ServiceAccount**
- Adds **IRSA annotation**

Example annotation:

```yaml
annotations:
  eks.amazonaws.com/role-arn: arn:aws:iam::ACCOUNT-ID:role/S3AccessRole
```

**Remark:**  
Links **AWS IAM Role with Kubernetes Service Account**.

---

# Step 4 — Create Pod Using Service Account

Create a file named:

### File: `aws-cli-pod.yaml`

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: aws-cli-pod
spec:
  serviceAccountName: s3-access-svc
  containers:
  - name: aws-cli
    image: amazonlinux:2
    command: ["sleep","3600"]
    tty: true
```

Apply the pod:

```bash
kubectl apply -f aws-cli-pod.yaml
```

**Remark:**  
The pod will **inherit IAM permissions through the ServiceAccount**.

---

# Step 5 — Login into the Pod

```bash
kubectl exec -it aws-cli-pod -- /bin/bash
```

**Remark:**  
Access the pod shell to run AWS CLI commands.

---

# Step 6 — Install AWS CLI Inside the Pod

```bash
yum install -y unzip curl

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"

unzip awscliv2.zip

./aws/install
```

Verify installation:

```bash
aws --version
```

**Remark:**  Installs **AWS CLI inside the container**.

---

# Step 7 — Test S3 Access

Run the following command inside the pod:

```bash
aws s3 ls
```

Example output:

```
2025-03-12 14:02:28 mysmh.co.in
2025-02-16 16:50:28 syedmujtaba
2025-04-24 09:50:11 syedredis
```

**Remark:**  Confirms that the **pod can access S3 using IRSA**.

---

# Debug Command (Very Important)

If S3 access fails, verify the IAM role used by the pod.

```bash
aws sts get-caller-identity
```

Example output:

```
{
  "UserId": "...",
  "Account": "123456789012",
  "Arn": "arn:aws:sts::123456789012:assumed-role/S3AccessRole/..."
}
```

**Remark:**  Shows **which IAM role the pod is currently using**.

---

# Key Takeaway

Instead of giving AWS permissions to the **node IAM role**, we use **IRSA** to give permission to a **specific pod**.

```
Node IAM Role → All Pods Get Permission ❌
ServiceAccount + IRSA → Only Required Pod Gets Permission ✅
```

---

# Memory Trick

```
1️⃣ Enable OIDC – Allow EKS to trust IAM.
2️⃣ Create IAM JSON file and with Policy – Define S3 permissions.
3️⃣ Create IAM Role – Attach the S3 policy.
4️⃣ Create ServiceAccount – Link the IAM role (IRSA).
5️⃣ Create Pod – Attach the ServiceAccount to the pod.
6️⃣ Test Access – Login into pod and run aws s3 ls.
```

Remember this flow for **IRSA interviews and troubleshooting**.
