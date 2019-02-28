# Example Project

This project shows how to integrate this cluster module into a project. The openstack provider will
be configured by either environment variables or your `clouds.yaml` setup. You have to provide the Authentication URL, 
Username and Password for the OpenStack cloud controller manager.

## Deployment

For the commands given, we assume you have sourced an `openrc.sh` file.
If not, please set the variables `OS_AUTH_URL`, `OS_PASSWORD` and `OS_USERNAME` appropriately. 

First of all you have to init the terraform plugins. Run:
```bash
terraform init
```

Then to show the changes this project will make:
```bash
terraform plan \
  -var=auth_url=${OS_AUTH_URL} \
  -var=password=${OS_PASSWORD} \
  -var=username=${OS_USERNAME}

```

Then apply the changes via:
```bash
terraform apply \
  -var=auth_url=${OS_AUTH_URL} \
  -var=password=${OS_PASSWORD} \
  -var=username=${OS_USERNAME}
```

Now follow the instructions [here](https://github.com/inovex/kubernetes-on-openstack#authentication) to setup your local
kubectl.