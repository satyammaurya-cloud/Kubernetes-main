## In Kubernetes there are two main types of API groups you usually see in RBAC.

#### Core API group      → " "
#### Named API groups    → apps, batch, networking.k8s.io, rbac.authorization.k8s.io, etc

#### 1️⃣ Core API Group:  **apiGroup: " "** :  This is the default (core) group.

Common resources: 
```yaml
pods
services
configmaps
secrets
namespaces
nodes
persistentvolumes
persistentvolumeclaims

# Example:1

apiGroups: [""]
resources: ["pods"]
verbs: ["get","list"]
---
# Example: 2
rules:
- apiGroups: [""]
  resources: ["configmaps","pods","services"]
  verbs: ["get","list"]

```

#### 2️⃣ Named API Groups:  These are separate API groups created by Kubernetes.

Examples:

| API Group | Resources |
|---|---|
| apps | deployments, daemonsets, replicasets, statefulsets |
| batch | jobs, cronjobs |
| networking.k8s.io | ingress, networkpolicies |
| rbac.authorization.k8s.io | roles, rolebindings, clusterroles, clusterrolebindings |
| autoscaling | horizontalpodautoscalers (HPA) |
| policy | poddisruptionbudgets |
| storage.k8s.io | storageclasses |

Example:
```yaml
- apiGroups: ["apps"]
  resources: ["deployments"]
  verbs: ["get","list"]
```

# Kubernetes RBAC Verbs

Common verbs used in RBAC:

- get
- list
- watch
- create
- update
- patch
- delete
- deletecollection

---

# Special RBAC Verbs

- impersonate
- bind
- escalate
- approve
- use

---

# Meaning of Common Verbs

| Verb | Purpose |
|-----|--------|
|get | Read a single resource |
|list | List multiple resources |
|watch | Watch changes in resources |
|create | Create a resource |
|update | Update/replace resource |
|patch | Modify part of resource |
|delete | Delete a resource |
|deletecollection | Delete multiple resources |

---

# Example RBAC Rule

```yaml
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get","list","watch"]
