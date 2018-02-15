# Terraform

Running Kubernetes on OpenStack with `kubeadm` and `terraform`

## Using the module

Create a `main.tf` with the following content (obviously set the variables to your real values):

```hcl
module "my_cluster" {
  source = "git::git@github.com:johscheuer/kubernetes-on-openstack.git?ref=v0.0.1"

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

When the machine has booted:

```bash
ssh ubuntu@<floating-ip>
```

To access the API server from external (as long as the Keystone auth doesn't work):

```bash
scp ubuntu@<floating-ip>:/home/ubuntu/.kube/config ~/.kube/my_cluster_config
# Adjust here the IP address of the server
export KUBECONFIG= ~/.kube/my_cluster_config
kubectl get cs
```

# TODO

- [x] Docs
- [ ] image (architecture)
- [ ] LB for API server
- [x] OpenStack integration (testing)
- [ ] Authentication over OpenStack (keystone)
- [ ] Create a module
- [ ] HA control plane (<https://kubernetes.io/docs/setup/independent/high-availability>)
- [ ] Add extra disks to master and worker
