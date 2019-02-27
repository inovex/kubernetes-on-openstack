# Configure the OpenStack Provider
provider "openstack" {
  version = "~> v1.6.0"

  user_name        = "${var.username}"
  domain_name      = "${var.domain_name}"
  tenant_name      = "${var.tenant_name}"
  user_domain_name = "${var.user_domain_name != "" ? var.user_domain_name : var.domain_name}"
  password         = "${var.password}"
  auth_url         = "${var.auth_url}"
  region           = "${var.region}"
}

provider "local" {
  version = "~> v1.1.0"
}

resource "openstack_compute_keypair_v2" "basic_keypair" {
  name       = "${var.cluster_name}_keypair"
  public_key = "${file(var.ssh_pub_key)}"
}

data "openstack_images_image_v2" "ubuntu" {
  name        = "${var.image_name}"
  most_recent = true
}

data "template_file" "master_init" {
  template = "${file("${path.module}/scripts/master.cfg.tpl")}"

  vars {
    bootstrap_token     = "${var.bootstrap_token != "" ? var.bootstrap_token : format("%s.%s", random_string.firstpart.result, random_string.secondpart.result)}"
    username            = "${var.username}"
    password            = "${var.password}"
    project_id          = "${var.project_id}"
    subnet_id           = "${openstack_networking_subnet_v2.cluster_subnet.id}"
    external_ip         = "${openstack_networking_floatingip_v2.public_ip.address}"
    kubernetes_version  = "${var.kubernetes_version}"
    pod_subnet          = "${var.pod_subnet}"
    public_network_id   = "${data.openstack_networking_network_v2.public.id}"
    auth_url            = "${var.auth_url}"
    domain_name         = "${var.domain_name}"
    node_security_group = "${openstack_networking_secgroup_v2.secgroup_node.id}"
    containerd_version  = "${var.containerd_version}"
  }
}

# Render a multi-part cloudinit config making use of the part
# above, and other source files
data "template_cloudinit_config" "master_config" {
  gzip          = false
  base64_encode = false

  part {
    content = "${data.template_file.master_init.rendered}"
  }
}

resource "openstack_compute_instance_v2" "master" {
  name            = "${var.cluster_name}-master"
  image_id        = "${data.openstack_images_image_v2.ubuntu.id}"
  flavor_name     = "${var.flavor}"
  key_pair        = "${openstack_compute_keypair_v2.basic_keypair.id}"
  security_groups = ["${openstack_networking_secgroup_v2.secgroup_master.id}", "${openstack_networking_secgroup_v2.secgroup_node.id}"]
  user_data       = "${data.template_cloudinit_config.master_config.rendered}"

  metadata {
    kubernetes = "master"
    cluster    = "${var.cluster_name}"
  }

  network {
    uuid = "${openstack_networking_network_v2.private.id}"
  }

  block_device {
    uuid                  = "${data.openstack_images_image_v2.ubuntu.id}"
    source_type           = "image"
    destination_type      = "local"
    boot_index            = 0
    delete_on_termination = true
  }

  block_device {
    source_type           = "blank"
    destination_type      = "volume"
    volume_size           = 200
    boot_index            = 1
    delete_on_termination = true
  }
}

data "template_file" "node_init" {
  template = "${file("${path.module}/scripts/node.cfg.tpl")}"

  vars {
    bootstrap_token     = "${var.bootstrap_token != "" ? var.bootstrap_token : format("%s.%s", random_string.firstpart.result, random_string.secondpart.result)}"
    username            = "${var.username}"
    password            = "${var.password}"
    project_id          = "${var.project_id}"
    subnet_id           = "${openstack_networking_subnet_v2.cluster_subnet.id}"
    api_server          = "${openstack_compute_instance_v2.master.access_ip_v4}"
    public_network_id   = "${data.openstack_networking_network_v2.public.id}"
    auth_url            = "${var.auth_url}"
    domain_name         = "${var.domain_name}"
    node_security_group = "${openstack_networking_secgroup_v2.secgroup_node.id}"
    containerd_version  = "${var.containerd_version}"
    kubernetes_version  = "${var.kubernetes_version}"
  }
}

# Render a multi-part cloudinit config making use of the part
# above, and other source files
data "template_cloudinit_config" "node_config" {
  gzip          = false
  base64_encode = false

  part {
    content = "${data.template_file.node_init.rendered}"
  }
}

resource "openstack_compute_instance_v2" "node" {
  count           = "${var.node_count}"
  name            = "${var.cluster_name}-node-${count.index}"
  image_id        = "${data.openstack_images_image_v2.ubuntu.id}"
  flavor_name     = "${var.flavor}"
  key_pair        = "${openstack_compute_keypair_v2.basic_keypair.id}"
  security_groups = ["${openstack_networking_secgroup_v2.secgroup_node.id}"]
  user_data       = "${data.template_cloudinit_config.node_config.rendered}"

  metadata {
    kubernetes = "node"
    cluster    = "${var.cluster_name}"
  }

  network {
    uuid = "${openstack_networking_network_v2.private.id}"
  }
}
