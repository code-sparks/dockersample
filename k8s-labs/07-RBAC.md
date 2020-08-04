# Configure RBAC in your Kubernetes Cluster

### Overview

This guide will go through the basic Kubernetes Role-Based Access Control (RBAC) API Objects. At the end of this guide, you should have enough knowledge to implement RBAC policies in your cluster. 

RBAC policies are enabled by default. RBAC policies are vital for the correct management of your cluster, as they allow you to specify which types of actions are permitted depending on the user and their role in your organization. Examples include:

- Secure your cluster by granting privileged operations (accessing secrets, for example) only to admin users.
- Force user authentication in your cluster.
- Limit resource creation (such as pods, persistent volumes, deployments) to specific namespaces. You can also use quotas to ensure that resource usage is limited and under control.
- Have a user only see resources in their authorized namespace. This allows you to isolate resources within your organization (for example, between departments).

## Getting started

One basic Kubernetes feature is that [all its resources are modeled API objects](https://kubernetes.io/docs/concepts/overview/working-with-objects/kubernetes-objects/), which allow CRUD (Create, Read, Update, Delete) operations. Examples of resources are:

- [Pods](https://kubernetes.io/docs/concepts/workloads/pods/pod/).
- [PersistentVolumes](https://kubernetes.io/docs/concepts/storage/volumes/).
- [ConfigMaps](https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/).
- [Deployments](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/).
- [Nodes](https://kubernetes.io/docs/concepts/architecture/nodes/).
- [Secrets](https://kubernetes.io/docs/concepts/configuration/secret/).
- [Namespaces](https://kubernetes.io/docs/user-guide/namespaces/).

Examples of possible operations over these resources are:

- *create*
- *get*
- *delete*
- *list*
- *update*
- *edit*
- *watch*
- *exec*

At a higher level, resources are associated with [API Groups](https://kubernetes.io/docs/concepts/overview/kubernetes-api/#api-groups) (for example, Pods belong to the *core* API group whereas Deployments belong to the *apps* API group). For more information about all available resources, operations, and API groups, check the [Official Kubernetes API Reference](https://kubernetes.io/docs/reference/kubernetes-api/).

To manage RBAC in Kubernetes, apart from resources and operations, we need the following elements:

- Rules: A rule is a set of operations (verbs) that can be carried out on a group of resources which belong to different API Groups.
- Roles and ClusterRoles: Both consist of rules. The difference between a Role and a ClusterRole is the scope: in a Role, the rules are applicable to a single namespace, whereas a ClusterRole is cluster-wide, so the rules are applicable to more than one namespace. ClusterRoles can define rules for cluster-scoped resources (such as nodes) as well. Both Roles and ClusterRoles are mapped as API Resources inside our cluster.
- Subjects: These correspond to the entity that attempts an operation in the cluster. There are three types of subjects:
  - User Accounts: These are global, and meant for humans or processes living outside the cluster. There is no associated resource API Object in the Kubernetes cluster.
  - Service Accounts: This kind of account is namespaced and meant for intra-cluster processes running inside pods, which want to authenticate against the API.
  - Groups: This is used for referring to multiple accounts. There are some groups created by default such as *cluster-admin* (explained in later sections).
- RoleBindings and ClusterRoleBindings: Just as the names imply, these bind subjects to roles (i.e. the operations a given user can perform). As for Roles and ClusterRoles, the difference lies in the scope: a RoleBinding will make the rules effective inside a namespace, whereas a ClusterRoleBinding will make the rules effective in all namespaces.

### Adding Routes

## Step 1: Create the office namespace

- Execute the *kubectl create* command to create the namespace (as the admin user):

  ```bash
  kubectl create namespace office
  ```

## Step 2: Create the user credentials

As previously mentioned, Kubernetes does not have API Objects for User Accounts. Of the available ways to manage authentication (see [Kubernetes official documentation](https://kubernetes.io/docs/admin/authentication) for a complete list), we will use OpenSSL certificates for their simplicity. The necessary steps are:

- Create a private key for your user. In this example, we will name the file *employee.key*:

  ```bash
  openssl genrsa -out employee.key 2048
  ```

- Create a certificate sign request *employee.csr* using the private key you just created (*employee.key* in this example). Make sure you specify your username and group in the *-subj* section (CN is for the username and O for the group). 

  ```bash
  openssl req -new -key employee.key -out employee.csr -subj "/CN=employee/O=organization"
  ```

- Generate the final certificate *employee.crt* by issuing certificate sign request 

  ```bash
  cat <<EOF | kubectl apply -f -
  apiVersion: certificates.k8s.io/v1beta1
  kind: CertificateSigningRequest
  metadata:
    name: employee
  spec:
    request: $(cat employee.csr | base64 | tr -d '\n')
    usages:
    - digital signature
    - key encipherment
    - server auth
    - client auth
  EOF
  ```

- ### Approve Certificate Request

  Get the list of CSRs

  ```
  kubectl get csr
  ```

  Approve the CSR

  ```
  kubectl certificate approve employee
  ```

  ### Get the Certificate

  Retrieve the Certificate from the approved CSR, and save it to a file

  ```
  kubectl get csr employee -o jsonpath='{.status.certificate}' | base64 --decode > employee.crt
  ```

  ### Add To  KubeConfig

  Add a new context with the new credentials for your Kubernetes cluster. 

  ```bash
  kubectl config set-credentials employee --client-certificate=employee.crt  --client-key=employee.key
  kubectl config set-context employee-context --cluster=kind-kind --namespace=office --user=employee
  ```

  Now you should get an access denied error when using the *kubectl* CLI with this configuration file. This is expected as we have not defined any permitted operations for this user.

  **Test**:

  ```bash
  kubectl --context=employee-context get pods
  ```



## Step 3: Create the role for managing deployments

- Create a *role-deployment-manager.yaml* file with the content below. In this *yaml* file we are creating the rule that allows a user to execute several operations on Deployments, Pods and ReplicaSets (necessary for creating a Deployment), which belong to the *core* (expressed by "" in the *yaml* file), *apps*, and *extensions* API Groups:

  ```yaml
  kind: Role
  apiVersion: rbac.authorization.k8s.io/v1beta1
  metadata:
    namespace: office
    name: deployment-manager
  rules:
  - apiGroups: ["", "extensions", "apps"]
    resources: ["deployments", "replicasets", "pods"]
    verbs: ["get", "list", "watch", "create", "update", "patch", "delete"] # You can also use ["*"]
  ```

- Create the Role in the cluster using the *kubectl create role* command:

  ```bash
  kubectl create -f role-deployment-manager.yaml
  ```

## Step 4: Bind the role to the employee user

- Create a *rolebinding-deployment-manager.yaml* file with the content below. In this file, we are binding the *deployment-manager* Role to the User Account *employee* inside the *office* namespace:

  ```yaml
  kind: RoleBinding
  apiVersion: rbac.authorization.k8s.io/v1beta1
  metadata:
    name: deployment-manager-binding
    namespace: office
  subjects:
  - kind: User
    name: employee
    apiGroup: ""
  roleRef:
    kind: Role
    name: deployment-manager
    apiGroup: ""
  ```

- Deploy the RoleBinding by running the *kubectl create* command:

  ```bash
  kubectl create -f rolebinding-deployment-manager.yaml
  ```

## Step 5: Test the RBAC rule

**switch context:**

```bash
kubectl config use-context employee-context
```

Create a simple deployment

```bash
kubectl run nginx --image=nginx
```

## 
