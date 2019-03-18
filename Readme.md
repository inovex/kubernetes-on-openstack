# Kubernetes on OpenStack

Deploying a Kubernetes cluster on OpenStack with `kubeadm` and `terraform`.

## Using the module

After cloning or downloading the repository, follow these steps to get your cluster up and running.

### Customize settings

Take a look at the example provided in the `example` folder. It contains three files: `main.tf`, `provider.tf`, and `variables.tf`. Have a look at `main.tf`. Customize settings like `master_data_volume_size` or `node_data_volume_size` to your needs, you might have to stay below quotas set by your OpenStack admin. Pick an instance flavor that has at least two vCPUs, otherwise kubeadm will fail during its pre-flight check.

We assume `example` to be your working directory for all following commands.

### Install keystone auth plugin

The Kubernetes cluster will use Keystone authentication (over a WebHook). For mor details look at the official [docs](https://github.com/kubernetes/cloud-provider-openstack/blob/master/docs/using-keystone-webhook-authenticator-and-authorizer.md#new-kubectl-clients-from-v1110-and-later) or just use the quick start:

```bash
VERSION=1.13.1
OS=$(uname | tr '[:upper:]' '[:lower:]')
curl -sLO "https://github.com/kubernetes/cloud-provider-openstack/releases/download/${VERSION}/cloud-provider-openstack-${VERSION}-${OS}-amd64.tar.gz"
tar xfz cloud-provider-openstack-${VERSION}-${OS}-amd64.tar.gz
rm cloud-provider-openstack-${VERSION}-${OS}-amd64.tar.gz

mkdir $(pwd)/bin
cp ${OS}-amd64/client-keystone-auth $(pwd)/bin/
rm -rf ${OS}-amd64
```

### Reference the module correctly

As long as you keep the `example` folder inside the module repository, the reference `source = "../"` in the `main.tf` works. For a cleaner setup, you can also extract the example folder and put it somewhere else, just make sure you change the source setting accordingly. You can also reference the GitHub repository itself like so:

```hcl
   module "my_cluster" {
     source = "git::https://github.com/inovex/kubernetes-on-openstack.git?ref=v1.0.0"

     # ...
   }
```

If you do it that way, make sure to

```bash
terraform get --update
```

before running any other terraform commands.

### Set your credentials

There a multiple different ways to authenticate with your OpenStack provider that all have their pros and cons. If you want to know more, check out this [blog post about OpenStack credential handling for terraform](https://www.inovex.de/blog/managing-secrets-openstack-terraform/). You can choose any of them, as long as you make sure the terraform variables `auth_url`, `username` and `password` are set explicitly as terraform variables. This is required as they are passed down to the Openstack Cloud Controller running inside the provisioned Kubernetes. Those should be dedicated service account credentials in a team setup. The easiest way to get started is to create a `terraform.tfvars` file in the `example` folder. If you start working in a team setup, you might want to check out the method using `clouds-public.yaml`, `clouds.yaml` and `secure.yaml` files in the aforementioned blog post.

### Execute terraform

Initialize the folder and run `plan`:

```bash
terraform init
terraform plan
```

Now you can create the cluster by running

```bash
terraform apply
```

It takes some time for the nodes to be fully configured. After running `terraform apply` there will be a kubeconfig file configured for the newly created cluster. The `--insecure-skip-tls-verify=true` in there is needed because we use the auto-generated certificates of kubeadm. There are possible workarounds to remove the flag (e.g. fetch the CA from the Kubernetes master, see below). Keep in mind: As a default all users in the (OpenStack) project will have `cluster-admin` rights. You can access the cluster via

```bash
kubectl --kubeconfig kubeconfig get nodes
```

It is also possible to set the `KUBECONFIG` environment variable to reference the location of the `kubeconfig` file created by terraform  or to copy its contents to your `.kube` settings but keep in mind that the kubeconfig changes often because of Floating IPs.

### Test the OpenStack integration

To create a simple deployment, run

```bash
kubectl --kubeconfig kubeconfig create deployment nginx --image=nginx
kubectl --kubeconfig kubeconfig expose deployment nginx --port=80
```

### Access nodes

In the current setup the master node can be reached by

```bash
ssh ubuntu@<ip>
```

and can also be used as jumphost to access the worker nodes:

```bash
ssh -J ubuntu@<ip> ubuntu@node-0
```

## Fetch cluster CA

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

## Shared environments

### Currently blocked

In order to create a shared Kubernetes cluster for multiple users we can use [application credentials](https://docs.openstack.org/python-openstackclient/rocky/cli/command-objects/application-credentials.html)

```bash
openstack --os-cloud <cloud> --os-project-id=<project-id> application credential create --restricted kubernetes
```

more docs will follow when the feature is merged.

## Notes

If you want to use containerd in version 1.2.2 you will probably face [this containerd issue](https://github.com/containerd/containerd/issues/2840) if you use images from [quay.io](https://quay.io)