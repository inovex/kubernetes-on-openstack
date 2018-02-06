# Configure the OpenStack Provider
provider "openstack" {
  version = "~> v1.2.0"

  user_name   = "${var.username}"
  domain_name = "${var.domain_name}"
  password    = "${var.password}"
  auth_url    = "${var.auth_url}"
  region      = "${var.region}"
}

resource "openstack_compute_keypair_v2" "basic_keypair" {
  name       = "basic_keypair"
  public_key = "${file(var.ssh_pub_key)}"
}

data "openstack_images_image_v2" "ubuntu" {
  name = "${var.image_name}"
  most_recent = true
}

data "template_file" "master_init" {
  template = "${file("${path.module}/scripts/master.cfg.tpl")}"

  vars {
    bootstrap_token = "${var.bootstrap_token != "" ? var.bootstrap_token : format("%s.%s", random_string.firstpart.result, random_string.secondpart.result)}"
    username        = "${var.username}"
    password        = "${var.password}"
    project_id      = "${var.project_id}"
    subnet_id       = "${data.openstack_networking_network_v2.public.id}"
    external_ip     = "${openstack_networking_floatingip_v2.public_ip.address}"
  }
}

# Render a multi-part cloudinit config making use of the part
# above, and other source files
data "template_cloudinit_config" "master_config" {
  gzip           = false
  base64_encode  = false

  part {
    content      = "${data.template_file.master_init.rendered}"
  }
}

resource "openstack_compute_instance_v2" "master" {
  name            = "kube-master"
  image_id        = "${data.openstack_images_image_v2.ubuntu.id}"
  flavor_name     = "${var.flavor}"
  key_pair        = "${openstack_compute_keypair_v2.basic_keypair.id}"
  security_groups = ["${openstack_compute_secgroup_v2.secgroup_master.id}", "${openstack_compute_secgroup_v2.secgroup_node.id}"]
  user_data       = "${data.template_cloudinit_config.master_config.rendered}"

  metadata {
    kubernetes    = "master"
  }

  network {
    name          = "${openstack_networking_network_v2.private.name}"
  }
}

data "template_file" "node_init" {
  template = "${file("${path.module}/scripts/node.cfg.tpl")}"

  vars {
    bootstrap_token = "${var.bootstrap_token != "" ? var.bootstrap_token : format("%s.%s", random_string.firstpart.result, random_string.secondpart.result)}"
    username        = "${var.username}"
    password        = "${var.password}"
    project_id      = "${var.project_id}"
    subnet_id       = "${data.openstack_networking_network_v2.public.id}" #TODO ->"${var.subnet_id}"
    api_server      = "${openstack_compute_instance_v2.master.access_ip_v4}"
  }
}

# Render a multi-part cloudinit config making use of the part
# above, and other source files
data "template_cloudinit_config" "node_config" {
  gzip           = false
  base64_encode  = false

  part {
    content      = "${data.template_file.node_init.rendered}"
  }
}

resource "openstack_compute_instance_v2" "node" {
  count           = "${var.node_count}"
  name            = "kube-node-${count.index}"
  image_id        = "${data.openstack_images_image_v2.ubuntu.id}"
  flavor_name     = "${var.flavor}"
  key_pair        = "${openstack_compute_keypair_v2.basic_keypair.id}"
  security_groups = ["${openstack_compute_secgroup_v2.secgroup_node.id}"]
  user_data       = "${data.template_cloudinit_config.node_config.rendered}"

  metadata {
    kubernetes    = "node"
  }

  network {
    name          = "${openstack_networking_network_v2.private.name}"
  }
}
