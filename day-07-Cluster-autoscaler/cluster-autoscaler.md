### 🔹 Cluster Autoscaler ?

Cluster Autoscaler is a Kubernetes component that automatically adjusts the number of nodes in a cluster based on pending pods and resource utilization.

### 🔹 Amazon EKS ?

Amazon EKS is a managed Kubernetes service by AWS that simplifies running Kubernetes clusters without managing control plane infrastructure.

### 🔹 Why Cluster Autoscaler in EKS ?

Cluster Autoscaler in EKS automatically scales EC2 worker nodes up or down to ensure pods are scheduled efficiently and cost is optimized.

### 🔹 How It Works ?

Cluster Autoscaler monitors unscheduled pods and node utilization, and interacts with AWS Auto Scaling Groups to add or remove nodes accordingly.

### 🔹 Workflow

`Pod pending → Autoscaler checks → Node added → Pod scheduled → Low usage → Node removed`

### 🔹 Prerequisites (Definition Style)

> EKS Cluster: Running Kubernetes cluster

> Worker Nodes: Managed/Unmanaged node group

> IAM Role: Required permissions for scaling

> kubectl: Configured access

---

## Cluster Autoscaler Setup on Amazon EKS 🚀 

This guide walks you through installing and configuring the **Cluster Autoscaler** on an Amazon EKS cluster using the AWS cloud provider.



#### 1️⃣ Deploy Cluster Autoscaler

Apply the official Cluster Autoscaler manifest for your Kubernetes version (adjust `1.29.0` if needed):

```sh
kubectl apply -f https://raw.githubusercontent.com/kubernetes/autoscaler/cluster-autoscaler-1.29.0/cluster-autoscaler/cloudprovider/aws/examples/cluster-autoscaler-autodiscover.yaml
```
#### 2️⃣ Verify the Pod
Check that the autoscaler pod is running in the kube-system namespace:
```sh
kubectl -n kube-system get pods -l app=cluster-autoscaler
```
> Expected output:
```sh
NAME                                  READY   STATUS    RESTARTS   AGE
cluster-autoscaler-6889f6cf54-7pcsh   1/1     Running   0          2m
```

#### 3️⃣ Edit Deployment (Add Cluster Name)

Edit the deployment to configure your cluster name:
```sh
kubectl -n kube-system edit deployment.apps/cluster-autoscaler
```
Inside the manifest, find the container args section and update your cluster name their: # or Copy and Paste yaml code thier

```sh
containers:
  - name: cluster-autoscaler
    - command:
        - ./cluster-autoscaler
        - --v=4
        - --stderrthreshold=info
        - --cloud-provider=aws
        - --skip-nodes-with-local-storage=false
        - --expander=least-waste
        - --node-group-auto-discovery=asg:tag=k8s.io/cluster-autoscaler/enabled,k8s.io/cluster-autoscaler/naresh  # Update your cluster name here 
# changed the cluster name in place of <Your cluster name> as my cluster name is naresh
        image: registry.k8s.io/autoscaling/cluster-autoscaler:v1.26.2
        imagePullPolicy: Always
        name: cluster-autoscaler
```
Save & exit.

#### 4️⃣ Configure IAM Permissions
Cluster Autoscaler requires IAM permissions to scale nodes.
Go to your EKS Node Group IAM Role and attach the following policy.

👉 Either attach AmazonEKSClusterAutoscalerPolicy (AWS Managed)
or create a custom IAM policy with the JSON below.

Example IAM Policy JSON

```sh
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "autoscaling:DescribeAutoScalingGroups",
        "autoscaling:DescribeAutoScalingInstances",
        "autoscaling:DescribeLaunchConfigurations",
        "autoscaling:DescribeTags",
        "autoscaling:SetDesiredCapacity",
        "autoscaling:TerminateInstanceInAutoScalingGroup",
        "ec2:DescribeLaunchTemplateVersions"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
```

Attach this to your Node Group Role.

#### 5️⃣ Update Node Group Scaling Config
Set your min/max/desired node counts for the autoscaler:
```sh
aws eks update-nodegroup-config \
  --cluster-name naresh \
  --nodegroup-name ng-af5ac006 \
  --scaling-config minSize=2,maxSize=6,desiredSize=3
```
#### 6️⃣ Check Autoscaler Logs
Watch the logs to confirm the autoscaler is working:
```sh
kubectl -n kube-system logs -f deployment/cluster-autoscaler
```
Look for lines like:
```sh
I0828 17:36:38.403432       1 scale_up.go:422] Pod default/nginx-deployment-12345 is unschedulable ...
I0828 17:36:38.403451       1 scale_up.go:423] Scale-up triggered ...
```
#### ✅ Validation
Deploy a test workload with more pods than your current node capacity:
```sh
kubectl create deployment nginx --image=nginx --replicas=50
```
Check if new nodes are being added:
```sh
kubectl get nodes -w
```
Scale down pods and watch nodes reduce (if below maxSize and above minSize):
```sh
kubectl scale deployment nginx --replicas=1
```
#### 📝 Notes
> Auto Scaling Configuration

- **minSize**: ensures at least 2 nodes are always running.
- **maxSize**: sets the upper scaling limit.
- **desiredSize**: is the starting point but will be adjusted dynamically.

## Important Notes

- Ensure your Node Group IAM Role has autoscaling permissions; otherwise, the pod will stay in Pending or fail to scale.
- Only one Cluster Autoscaler pod should be running per cluster (it uses leader election).
