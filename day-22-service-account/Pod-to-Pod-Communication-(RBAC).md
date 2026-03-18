# Kubernetes Service Account – Pod to Pod Communication (RBAC)

This example shows how a **Pod can access Kubernetes resources (like Pods)** using a **ServiceAccount with RBAC permissions**.

---

## Step 1 – Create ServiceAccount

Create a ServiceAccount that will be used by the pod.

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: my-service-account
  namespace: default
```

Apply:

```bash
kubectl apply -f service-account.yaml
```

---

## Step 2 – Create Role

Create a **Role** that allows reading pods.

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pod-reader-role
  namespace: default
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get","list"]
```

Apply:

```bash
kubectl apply -f role.yaml
```

---

## Step 3 – Create RoleBinding

Bind the **Role** to the **ServiceAccount**.

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: pod-reader-role-binding
  namespace: default
subjects:
- kind: ServiceAccount
  name: my-service-account
  namespace: default
roleRef:
  kind: Role
  name: pod-reader-role
  apiGroup: rbac.authorization.k8s.io
```

Apply:

```bash
kubectl apply -f rolebinding.yaml
```

---

## Step 4 – Create Pod Using ServiceAccount

Attach the ServiceAccount to the pod.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: myapp
  labels:
    app: webapp
    type: front-end
spec:
  serviceAccountName: my-service-account
  containers:
  - name: nginx-container
    image: nginx
```

Apply:

```bash
kubectl apply -f pod.yaml
```

---

## Step 5 – Verify Permissions

Login into the pod:

```bash
kubectl exec -it myapp -- /bin/bash
```

Try listing pods:

```bash
kubectl get pods
```

If permissions are correct, the command will work.

---

#### Conclusion

- **ServiceAccount** → Identity used by pods.
- **Role** → Defines permissions.
- **RoleBinding** → Assigns the Role to the ServiceAccount.
- **Pod** → Uses the ServiceAccount to access Kubernetes resources.

---

#### Access Flow

```
Pod
 ↓
ServiceAccount
 ↓
Role
 ↓
RoleBinding
 ↓
Kubernetes API
```
