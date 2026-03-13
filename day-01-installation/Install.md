# Setup Kubernetes on Amazon EKS

You can follow same procedure in the official  AWS document [Getting started with Amazon EKS – eksctl](https://docs.aws.amazon.com/eks/latest/userguide/getting-started-eksctl.html)   

#### Pre-requisites: 
  - an EC2 Instance 

#### AWS EKS Setup 
1. Setup kubectl   
   a. Download kubectl version 1.20  
   b. Grant execution permissions to kubectl executable   
   c. Move kubectl into /usr/local/bin   
   d. Test that your kubectl installation was successful    
   ```sh 
   curl -o kubectl https://amazon-eks.s3.us-west-2.amazonaws.com/1.19.6/2021-01-05/bin/linux/amd64/kubectl
   chmod +x ./kubectl
   mv ./kubectl /usr/local/bin 
   kubectl version --short --client

   ## Download Latest kubectl ###
   
   curl -LO https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl
   chmod +x ./kubectl
   sudo mv ./kubectl /usr/local/bin
   kubectl version --client
   ---
   kubectl auth whoami


   ```
2. Setup eksctl   
   a. Download and extract the latest release   
   b. Move the extracted binary to /usr/local/bin   
   c. Test that your eksclt installation was successful   
   ```sh
   curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
   sudo mv /tmp/eksctl /usr/local/bin
   eksctl version
   ```
  
3. Create an IAM Role and attache it to EC2 instance    
   `Note: create IAM user with programmatic access if your bootstrap system is outside of AWS`   
   IAM user should have access to   
   IAM   
   EC2   
   VPC    
   CloudFormation

4. Create your cluster and nodes 
   ```sh
   Example: 1
   eksctl create cluster --name my-eks-cluster \
   --region us-east-1 \
   --node-type t2.small \
   
   Example: 2
   If You Want Better Naming, you can give the name to nodegroup.(Recommended)
   eksctl create cluster --name dev-cluster \
   --region us-east-1 \
   --nodegroup-name dev-workers \
   --node-type t2.small
   ---

   Creation Template :
   eksctl create cluster --name cluster-name  \
   --region region-name \
   --node-type instance-type \
   --nodes-min 2 \
   --nodes-max 2 \ 
   --zones <AZ-1>,<AZ-2>
   Example:
   eksctl create cluster --name my-eks  \
   --region us-east-1 \
   --node-type t2.medium \
   --nodes-min 2 \
   --nodes-max 4
   ```
5. To delete the EKS clsuter 
   ```sh 
   eksctl delete cluster my-eks-cluster --region us-east-1
   ```
   
6. Validate your cluster using by creating by checking nodes and by creating a pod 
   ```sh 
   kubectl get nodes
   ```

---
### ------- Docker and Minikube install process-----

### choose instance t2.medium    -> 2cpu 2gb ram required 
-----Install Docker first
  ```sh 
sudo dnf install docker -y   

sudo systemctl start docker.service ---to start thr docker service

sudo systemctl enable docker.service  --- to enable docker

sudo usermod -a -G docker ec2-user  --- to add the user ec2-user to the docker group 

newgrp docker --to run new group make changes immediatly

  ```
 
 ### ------Minikube ------
  ```sh 
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64

sudo install minikube-linux-amd64 /usr/local/bin/minikube

to start minikube ---minikube start 
to check status ----minikube status 
  ```

### ----------kubectl-----------
  ```sh 
curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl

chmod +x ./kubectl  -----Make the kubectl binary executable

sudo mv ./kubectl /usr/local/bin/kubectl  ----sudo mv ./kubectl /usr/local/bin/kubectl

  ```
