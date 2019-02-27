### Inital VPC setup
resource "openstack_networking_network_v2" "private" {
  name           = "${var.cluster_name}"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "cluster_subnet" {
  name       = "${var.cluster_name}_subnet"
  network_id = "${openstack_networking_network_v2.private.id}"
  cidr       = "${var.cluster_network_node_cidr}"
  ip_version = 4
}

data "openstack_networking_network_v2" "public" {
  name = "public"
}

data "openstack_networking_secgroup_v2" "default" {
  name = "default"
}

resource "openstack_networking_router_interface_v2" "cluster_subnet_interface" {
  router_id = "${var.cluster_network_router_id}"
  subnet_id = "${openstack_networking_subnet_v2.cluster_subnet.id}"
}

resource "openstack_networking_floatingip_v2" "public_ip" {
  pool = "${data.openstack_networking_network_v2.public.name}"
}

resource "openstack_compute_floatingip_associate_v2" "master" {
  floating_ip = "${openstack_networking_floatingip_v2.public_ip.address}"
  instance_id = "${openstack_compute_instance_v2.master.id}"
}

## Security groups for the Kubernetes master
resource "openstack_networking_secgroup_v2" "secgroup_master" {
  name        = "secgroup_master_${var.cluster_name}"
  description = "Allow access to the API server"
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_master_rule_api" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 6443
  port_range_max    = 6443
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.secgroup_master.id}"
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_master_rule_ssh" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.secgroup_master.id}"
}

resource "openstack_networking_secgroup_v2" "secgroup_node" {
  name        = "secgroup_nodes_${var.cluster_name}"
  description = "Allow network functionality for kubelet"
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_node_rule_icmp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.secgroup_node.id}"
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_node_rule_kubelet" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 10250
  port_range_max    = 10250
  remote_group_id   = "${openstack_networking_secgroup_v2.secgroup_master.id}"
  security_group_id = "${openstack_networking_secgroup_v2.secgroup_node.id}"
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_node_rule_heapster" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 10255
  port_range_max    = 10255
  remote_group_id   = "${openstack_networking_secgroup_v2.secgroup_master.id}"
  security_group_id = "${openstack_networking_secgroup_v2.secgroup_node.id}"
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_node_rule_allow_inside" {
  direction         = "ingress"
  ethertype         = "IPv4"
  remote_group_id   = "${openstack_networking_secgroup_v2.secgroup_node.id}"
  security_group_id = "${openstack_networking_secgroup_v2.secgroup_node.id}"
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_node_rule_nodeport" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 30000
  port_range_max    = 32767
  remote_group_id   = "${data.openstack_networking_secgroup_v2.default.id}"
  security_group_id = "${openstack_networking_secgroup_v2.secgroup_node.id}"
}

# Network rules for the loadbalancer
resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_allow_http" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${data.openstack_networking_secgroup_v2.default.id}"
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_allow_https" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 443
  port_range_max    = 443
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${data.openstack_networking_secgroup_v2.default.id}"
}
