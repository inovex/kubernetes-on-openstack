# Terraform

Running Kubernetes on OpenStack with `kubeadm` and `terraform`

## Using the module

Create a `main.tf` with the following content (obviously set the variables to your real values):

```hcl

data "openstack_networking_network_v2" "public" {
  name = "public"
}


resource "openstack_networking_router_v2" "router" {
  name                = "my_router"
  admin_state_up      = "true"
  external_network_id = "${data.openstack_networking_network_v2.public.id}"
}


module "my_cluster" {
  source = "git::https://github.com/johscheuer/kubernetes-on-openstack.git?ref=v0.0.4"

  auth_url                  = "auth_url"
  cluster_name              = "cluster_name"
  username                  = "username"
  password                  = "password"
  domain_name               = "domain_name"
  tenant_name               = "tenant_name"
  user_domain_name          = "user_domain_name"
  project_id                = "project_id"
  image_name                = "image_name"
  
  kubernetes_version        = "1.13.2"
  containerd_version        = "1.2.3"
  cluster_network_router_id = "${openstack_networking_router_v2.router.id}"
}

resource "local_file" "kubeconfig" {
  content  = "${module.my_cluster.kubeconfig}"
  filename = "${path.module}/kubeconfig"
}
```

Fetch the module, initialize the folder and run `plan`:

```bash
terraform get --update
terraform init
terraform plan
```

Now you can create the cluster:

```bash
terraform apply
```

## Authentication

The Kubernetes cluster will use Keystone authentication (over a WebHook). For more information have a look [here](https://github.com/kubernetes/cloud-provider-openstack/blob/master/docs/using-keystone-webhook-authenticator-and-authorizer.md). After running `terraform apply` there will be a kubeconfig file configured for the newly created cluster. The `--insecure-skip-tls-verify=true` in the kubeconfig fils is needed because we use the auto-generated certificates of kubeadm. There are possible workarounds to remove the flag (e.g. fetch the ca from the Kubernetes master).

Keep in mind: As a default all users in the (OpenStack) project will have `cluster-admin` rights.

### Install the keystone auth plugin

For mor details look at the official [docs](https://github.com/kubernetes/cloud-provider-openstack/blob/master/docs/using-keystone-webhook-authenticator-and-authorizer.md#new-kubectl-clients-from-v1110-and-later) or just use the quick start:

```bash
VERSION=1.13.1
OS=$(uname | tr '[:upper:]' '[:lower:]')
curl -sLO "https://github.com/kubernetes/cloud-provider-openstack/releases/download/${VERSION}/cloud-provider-openstack-${VERSION}-${OS}-amd64.tar.gz"
tar xfz cloud-provider-openstack-${VERSION}-${OS}-amd64.tar.gz
rm cloud-provider-openstack-${VERSION}-${OS}-amd64.tar.gz

cp ${OS}-amd64/client-keystone-auth $(pwd)/bin/
rm -rf ${OS}-amd64
```

Now you can use the kubeconfig with `kubectl --kubeconfig kubeconfig get nodes` or set `export KUBECONFIG="$(pwd)/kubeconfig"` to interact with the cluster.

In order to prevent to use `insecure-skip-tls-verify=true` you can fetch the cluster CA:

```bash
export MASTER_IP=""
export CLUSTER_CA=$(curl -sk "https://${MASTER_IP}:6443/api/v1/namespaces/kube-public/configmaps/cluster-info" | jq -r '.data.kubeconfig' | grep -o 'certificate-authority-data:.*' | awk '{print $2}')
# ${CLUSTER_NAME} must match the name provided in the terraform.tfvars
export CLUSTER_NAME=""

kubectl --kubeconfig ./kubeconfig config set clusters.${CLUSTER_NAME}.certificate-authority-data ${CLUSTER_CA}
kubectl --kubeconfig ./kubeconfig config set clusters.${CLUSTER_NAME}.insecure-skip-tls-verify false

unset CLUSTER_CA
unset MASTER_IP
unset CLUSTER_NAME
```

## Automatically deployed components

- [cloud-provider-openstack](https://github.com/kubernetes/cloud-provider-openstack)
- [calico](https://docs.projectcalico.org/v3.4/getting-started/kubernetes/installation/calico#installing-with-the-kubernetes-api-datastore50-nodes-or-less)

## Test the OpenStack integration

```bash
kubectl create deployment nginx --image=nginx
kubectl expose deployment nginx --port=80 --type=LoadBalancer
```

## Access nodes

In the current setup the master node can be used as jumphost:

```bash
ssh -J ubuntu@master ubuntu@node-0
```

## Shared environments

**Currently blocked**

In order to create a shared Kubernetes cluster for multiple users we can use [application credentials](https://docs.openstack.org/python-openstackclient/rocky/cli/command-objects/application-credentials.html)

```bash
openstack --os-cloud <cloud> --os-project-id=<project-id> application credential create --restricted kubernetes
```

more docs will follow when the feature is merged.

# Notes

If you want to use containerd in version 1.2.2 you will probably face this issue if you use images from [quay.io](https://quay.io) -> https://github.com/containerd/containerd/issues/2840

# TODO

- [x] Adjust Docs (for module + kubeconfig)
- [ ] image (architecture)
- [ ] LB for API server
- [x] OpenStack integration (testing)
- [x] Authentication over OpenStack (keystone)
- [x] Create a module
- [ ] HA control plane (<https://kubernetes.io/docs/setup/independent/high-availability>)
- [ ] Add extra disks to master and worker
- [X] Use [containerd](https://containerd.io)
- [X] Use Master as Jumphost
- [ ] Add Variable for OpenStack Controller version
