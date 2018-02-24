# Terraform

Running Kubernetes on OpenStack with `kubeadm` and `terraform`

## Using the module

Create a `main.tf` with the following content (obviously set the variables to your real values):

```hcl
module "my_cluster" {
  source = "git::https://github.com/johscheuer/kubernetes-on-openstack.git?ref=v0.0.1"

  auth_url      = "auth_url"
  cluster_name  = "cluster_name"
  username      = "username"
  password      = "password"
  domain_name   = "domain_name"
  project_id    = "project_id"
  image_name    = "image_name"
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

The Kubernetes cluster will use Keystone authentication (over a WebHook). For more information have a look [here](https://github.com/dims/openstack-cloud-controller-manager/blob/master/docs/using-keystone-webhook-authenticator-and-authorizer.md). After running `terraform apply` there will be output how to authenticate against the newly created cluster. In order to actually authenticate with KeyStone you need to perform the following steps described [here](https://github.com/dims/openstack-cloud-controller-manager/blob/master/docs/using-keystone-webhook-authenticator-and-authorizer.md#k8s-kubectl-client-configuration). The `--insecure-skip-tls-verify=true` is needed because we use the auto-generated certificates of kubeadm. There are possible workarounds to remove the flag (e.g. fetch the ca from the Kubernetes master).

Keep in mind: As a default all users in the (OpenStack) project will have `cluster-admin` rights.

### Deprecated

When the machine has booted:

```bash
ssh ubuntu@<floating-ip>
```

To access the API server from external (as long as the Keystone auth doesn't work):

```bash
scp ubuntu@<floating-ip>:/home/ubuntu/.kube/config ~/.kube/my_cluster_config
export KUBECONFIG=~/.kube/my_cluster_config
kubectl get cs
```

# TODO

- [x] Docs
- [ ] image (architecture)
- [ ] LB for API server
- [x] OpenStack integration (testing)
- [x] Authentication over OpenStack (keystone)
- [x] Create a module
- [ ] HA control plane (<https://kubernetes.io/docs/setup/independent/high-availability>)
- [ ] Add extra disks to master and worker
- [ ] Use Clear Containers
