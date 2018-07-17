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

The Kubernetes cluster will use Keystone authentication (over a WebHook). For more information have a look [here](https://github.com/dims/openstack-cloud-controller-manager/blob/master/docs/using-keystone-webhook-authenticator-and-authorizer.md). After running `terraform apply` there will be output how to authenticate against the newly created cluster. In order to actually authenticate with KeyStone you need to perform the following steps described [here](https://github.com/dims/openstack-cloud-controller-manager/blob/master/docs/using-keystone-webhook-authenticator-and-authorizer.md#k8s-kubectl-client-configuration). The `--insecure-skip-tls-verify=true` is needed because we use the auto-generated certificates of kubeadm. There are possible workarounds to remove the flag (e.g. fetch the ca from the Kubernetes master). In order to use the keystone auth we need to install the [keystone-auth plugin](https://github.com/kubernetes/cloud-provider-openstack/blob/master/docs/using-client-keystone-auth.md)

Keep in mind: As a default all users in the (OpenStack) project will have `cluster-admin` rights.

### Install the keystone auth plugin

```bash
VERSION=v0.1.0
OS=$(uname | tr '[:upper:]' '[:lower:]')
curl -sLO https://github.com/kubernetes/cloud-provider-openstack/releases/download/${VERSION}/cloud-provider-openstack-${VERSION}-${OS}-amd64.tar.gz
tar xfz cloud-provider-openstack-${VERSION}-${OS}-amd64.tar.gz
rm cloud-provider-openstack-${VERSION}-${OS}-amd64.tar.gz

cp ${OS}-amd64/client-keystone-auth $(pwd)/bin/
rm -rf ${OS}-amd64
```

Now you can use the kubeconfig with `kubectl --kubeconfig kubeconfig get nodes` or set `export KUBECONFIG="$(pwd)/kubeconfig"` to interact with the cluster.

## Deploy the OpenStack Cloud provider

**This step is done automatically** In this step we deploy the [cloud-provider-openstack](https://github.com/kubernetes/cloud-provider-openstack) which allows us to create OpenStack LoadBalancer and Cinder Volumes as needed.

```bash
kubectl apply -f manifests/openstack-ccm.yml
```

## Test the OpenStack integration

```bash
kubectl run nginx --image=nginx --port=80
kubectl expose deployment nginx --port=80 --type=LoadBalancer
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
- [ ] Use Master as Jumphost
