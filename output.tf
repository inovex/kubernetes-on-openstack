output "master_ip" {
  value = "ssh ubuntu@${openstack_networking_floatingip_v2.public_ip.address}"
}

data "template_file" "kubeconfig" {
  template = "${file("${path.module}/templates/kubeconfig.tpl")}"

  vars {
    username          = "${var.username}"
    password          = "${var.password}"
    auth_url          = "${var.auth_url}"
    domain_name       = "${var.domain_name}"
    api_server_url    = "https://${openstack_networking_floatingip_v2.public_ip.address}:6443"
    cluster_name      = "${var.cluster_name}"
    auth_plugin       = "${pathexpand("./bin/client-keystone-auth")}"
  }
}

resource "local_file" "kubeconfig" {
    content     = "${data.template_file.kubeconfig.rendered}"
    filename    = "${path.module}/kubeconfig"
}
