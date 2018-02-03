# Terraform

Running Kubernetes on OpenStack with `kubeadm` and `terraform`

```bash
terraform init
terraform plan

# create resources
terraform apply
```

When the machine has booted:

```bash
ssh ubuntu@<floating-ip>
```

# TODO

- [ ] Docs
- [ ] image (architecture)
- [ ] LB for API server
- [ ] OpenStack integration (testing)
- [ ] Authentication over OpenStack (keystone)
- [ ] Create a module
