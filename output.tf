output "master_ip" {
  value = "ssh ubuntu@${openstack_networking_floatingip_v2.public_ip.address}"
}

output "login" {
  value = <<login
kubectl config set-cluster --insecure-skip-tls-verify=true --server='https://${openstack_networking_floatingip_v2.public_ip.address}:6443' ${var.cluster_name}
kubectl config set-credentials ${var.username} --auth-provider=openstack
kubectl config set-context --cluster=${var.cluster_name} --user=${var.username}  ${var.username}
kubectl config use-context ${var.username}
    login
}
