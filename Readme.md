# Terraform

Running Kubernetes on OpenStack with `kubeadm` and `terraform`

## Using the module

Create a `main.tf` with the following content (obviously set the variables to your real values):

```hcl
module "my_cluster" {
  source = "git::https://github.com/johscheuer/kubernetes-on-openstack.git?ref=v0.0.2"

  auth_url          = "auth_url"
  cluster_name      = "cluster_name"
  username          = "username"
  password          = "password"
  domain_name       = "domain_name"
  tenant_name       = "tenant_name"
  user_domain_name  = "user_domain_name"
  project_id        = "project_id"
  image_name        = "image_name"
  # kubernetes_version  = "1.13.2"
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
export CLUSTER_CA=$(curl -sk https://185.113.124.129:6443/api/v1/namespaces/kube-public/configmaps/cluster-info | jq -r '.data.kubeconfig' | grep -o 'certificate-authority-data:.*' | awk '{print $2}')

# ${cluster_name} must match the name above
kubectl config set clusters.${cluster_name}.certificate-authority-data ${CLUSTER_CA}
kubectl config set clusters.${cluster_name}.insecure-skip-tls-verify false
```

## Automatically deployed components

- [cloud-provider-openstack](https://github.com/kubernetes/cloud-provider-openstack)
- [calico](https://docs.projectcalico.org/v3.4/getting-started/kubernetes/installation/calico#installing-with-the-kubernetes-api-datastore50-nodes-or-less)

## Test the OpenStack integration

```bash
kubectl run nginx --image=nginx --port=80
kubectl expose deployment nginx --port=80 --type=LoadBalancer
```

## Access nodes

In the current setup the master node can be used as jumphost:

```bash
ssh -J ubuntu@master ubuntu@node-0
```

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
- [ ] Test application credentials