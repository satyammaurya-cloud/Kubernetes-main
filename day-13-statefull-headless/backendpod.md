### Kubernetes DNS Testing (BusyBox Pod) – for test and dubug linux lightweight image

#### Step-1: Create Debug Pod (BusyBox)
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: dns-client
spec:
  containers:
  - name: dns-client
    image: busybox
    command: ["sleep", "3600"]
```
- Apply Pod
```kubectl apply -f pod.yml```

- Login into Pod ```kubectl exec -it dns-client -- sh```

#### Step-2: Test Service DNS

Test Normal Service (ClusterIP)

```yaml
nslookup <service-name>

# Output:
- Returns Cluster IP
- Traffic goes to ANY pod (load balanced)

✔️ Concept:
- Client → Service (ClusterIP) → Random Pod

```
#### Step-3: Test Headless Service
```yaml
nslookup <headless-service-name>

# Output:
- Returns list of Pod IPs
- No load balancing by service

✔️ Concept:
- Client → Direct Pod (No ClusterIP)
```

#### Step-4: Access Specific Pod (Headless DNS)

📌 DNS Format:
```yaml
<pod-name>.<headless-service-name>.<namespace>.svc.cluster.local

# Example:

nslookup mysql-0.mysql.default.svc.cluster.local
nslookup mysql-1.mysql.default.svc.cluster.local
nslookup mysql-2.mysql.default.svc.cluster.local


✅ Result:
- Resolves to specific pod IP
- Direct communication to that pod
```

---

#### Key Difference (Important for Interview 🔥)

| Feature         | ClusterIP Service | Headless Service            |
|----------------|------------------|-----------------------------|
| DNS Result     | Cluster IP       | Pod IPs                     |
| Load Balancing | Yes              | No                          |
| Routing        | Random Pod       | Specific Pod                |
| Use Case       | Normal apps      | Stateful apps (DB, Kafka)   |


#### Super Short Revision (⚡)

- ClusterIP → One IP → Load balanced → Any pod
- Headless → No IP → Direct pod access → Stateful apps

Pod DNS:
```yaml
<pod>.<headless-svc>.<ns>.svc.cluster.local
"mysql-0.mysql.default.svc.cluster.local"
```
