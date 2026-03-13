---------------------------------------------- RBAC process
----------------------------------------------------------

RBAC (Role-Based Access Control) controls who can do what in your
Kubernetes cluster.

Roles / ClusterRoles → Define what actions are allowed.

RoleBindings / ClusterRoleBindings → Define who can perform those
actions.

IAM (AWS Identity and Access Management) users/roles can be mapped to
Kubernetes users via a ConfigMap:aws-auth in the kube-system namespace.

You can then assign these identities Kubernetes permissions using RBAC.

  -------------------------------------------------------------------------------------
  Component                Meaning                           Example
  ------------------------ --------------------------------- --------------------------
  **Role**                 Says *what actions* are allowed.  "Can read pods"

  **ClusterRole**          Like Role, but works across the   "Can read pods in all
                           *whole cluster*.                  namespaces"

  **RoleBinding**          Connects a *Role* to a *User* or  "Give Alice the pod-reader
                           *Group*.                          role in the dev namespace"

  **ClusterRoleBinding**   Connects a *ClusterRole* to a     "Give Bob admin access
                           *User/Group* for the *whole       everywhere"
                           cluster*.                         
  -------------------------------------------------------------------------------------

### Role vs Cluster role

  --------------------------------------------------------------------------
  Feature                       **Role**                **ClusterRole**
  ----------------------------- ----------------------- --------------------
  **Scope**                     Works **only inside one Works **across the
                                namespace**             whole cluster**

  **Can manage namespaced       ✅ Yes                  ✅ Yes
  resources**                                           

  **Can manage cluster-wide     ❌ No                   ✅ Yes
  resources** (like nodes,                              
  namespaces)                                           

  **Binding type used**         RoleBinding             ClusterRoleBinding

  **Example use**               Give a developer access Give admin access to
                                to pods in `dev`        alnamespaces
                                namespace               
  --------------------------------------------------------------------------

Step-1 Need to create IAM user with EKS cluster permission

Step-2 aws configure --profile IAMuser

`<ACCESS_KEY_ID>`{=html} (AccessKey)

`<SECRET_ACCESS_KEY>`{=html} (SecretKey)

step-3 create kuberenetes Role

step-4 cretae kuberentes role binding to bind role and group

step-5 add user arn into config map file

# Role

1.  Role A Role defines permissions (what actions can be performed)
    within a specific namespace. It cannot provide cluster-wide access;
    for that, use ClusterRole.
    ==============================================================

kind: Role apiVersion: rbac.authorization.k8s.io/v1 metadata: namespace:
default name: developer-role rules: - apiGroups: \[""\] \# "" indicates
the core API group \["apps"\] resources: \["ConfigMap"\] verbs: \["get",
"list"\] - apiGroups: \[""\] \# "" indicates the core API group
\["apps"\] resources: \["pods"\] verbs: \["get", "list",\] - apiGroups:
\["apps"\] resources: \["deployments"\] verbs: \["get", "list"\]

------------------Cluster role and cluster role binding --------------

======================== all permissions =====================

kind: ClusterRole apiVersion: rbac.authorization.k8s.io/v1 metadata:
name: cluster-admin-custom rules: - apiGroups: \["\*"\] resources:
\["\*"\] verbs: \["\*"\]

------------------------------------------------------------------------

kind: ClusterRoleBinding apiVersion: rbac.authorization.k8s.io/v1
metadata: name: cluster-admin-custom-binding subjects: - kind: Group
name: admin-team apiGroup: rbac.authorization.k8s.io roleRef: kind:
ClusterRole name: cluster-admin-custom apiGroup:
rbac.authorization.k8s.io

A RoleBinding assigns a Role to a specific user, group. It allows users
to perform the actions specified in the Role within a namespace.

========================================== kind: RoleBinding apiVersion:
rbac.authorization.k8s.io/v1 metadata: name: read-pods namespace:
default subjects: - kind: Group name: "developer" apiGroup:
rbac.authorization.k8s.io roleRef: kind: Role name: developer-role
apiGroup: rbac.authorization.k8s.io

#Edit command and add below user details

#kubectl edit cm aws-auth -n kube-system

# #aws auth config

mapUsers: \| - userarn: arn:aws:iam::381491944316:user/user-1 username:
user-1 groups: - developer

=================================User with admin
access===========================

mapUsers: \| - userarn: arn:aws:iam::381491944316:user/user-1 username:
user-1 groups: - system:masters

############# below block need to be added aws-auth ################3

mapRoles: \| - groups: - system:bootstrappers - system:nodes rolearn:
arn:aws:iam::545009827818:role/eksctl-naresh-nodegroup-ng-2b5f9fe-NodeInstanceRole-Fifi7BsDcajz
username: system:node:{{EC2PrivateDNSName}} mapUsers: \| - userarn:
arn:aws:iam::545009827818:user/user-1 username: user-1 groups: -
system:masters

# note: In Kubernetes, system:masters is a built-in cluster-admin group that provides full administrative access to the cluster.

mapRoles: \| - groups: - system:bootstrappers - system:nodes rolearn:
arn:aws:iam::545009827818:role/eksctl-naresh-nodegroup-ng-2b5f9fe-NodeInstanceRole-Fifi7BsDcajz
username: system:node:{{EC2PrivateDNSName}} - groups:\
- system:masters rolearn: arn:aws:iam::545009827818:role/ec2-admin2
username: ec2-admin2

################################# Custom Permissions

kubectl get rb kubectl get rolebinding kubectl api-resources

# to add user into aws-auth file

kubectl edit cm aws-auth -n kube-system

kubectl get cm -n kube-system

====================================================================

###### ================== Service accounts =====================

apiVersion: v1 kind: ServiceAccount metadata: name: my-service-account
namespace: default

###Create a Role for the Service Account apiVersion:
rbac.authorization.k8s.io/v1 kind: Role metadata: name: pod-reader
namespace: default rules: - apiGroups: \[""\] resources: \["pods"\]
verbs: \["get", "list"\]

## Bind the Role to the Service Account.yaml

apiVersion: rbac.authorization.k8s.io/v1 kind: RoleBinding metadata:
name: pod-reader-binding namespace: default subjects: - kind:
ServiceAccount name: my-service-account namespace: default roleRef:
kind: Role name: pod-reader apiGroup: rbac.authorization.k8s.io

## Use the Service Account in a Pod yaml

apiVersion: v1 kind: Pod metadata: name: myapp spec: serviceAccountName:
my-service-account containers: - name: nginx-container image: nginx

####################### Kubernetes EKS pod communication to AWS services

######### S3 access through pod

step 1:- create a json permission file for s3 access

{ "Version": "2012-10-17", "Statement": \[ { "Effect": "Allow",
"Action": \[ "s3:ListAllMyBuckets", "s3:ListBucket" \], "Resource": "\*"
} \] }
