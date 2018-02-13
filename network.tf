### Inital VPC setup
resource "openstack_networking_network_v2" "private" {
  name           = "private"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "subnet_private" {
  name            = "subnet_private"
  network_id      = "${openstack_networking_network_v2.private.id}"
  cidr            = "172.16.0.0/16"
  ip_version      = 4
  #dns_nameservers = ["8.8.8.8", "8.8.4.4"]
}

data "openstack_networking_network_v2" "public" {
  name = "public"
}
# Warning: openstack_networking_router_v2.private_router: "external_gateway": [DEPRECATED] use external_network_id instead
resource "openstack_networking_router_v2" "private_router" {
  name                = "private_router"
  admin_state_up      = "true"
  external_network_id = "${data.openstack_networking_network_v2.public.id}"
}

resource "openstack_networking_router_interface_v2" "private_router_interface" {
  router_id = "${openstack_networking_router_v2.private_router.id}"
  subnet_id = "${openstack_networking_subnet_v2.subnet_private.id}"
}

resource "openstack_networking_floatingip_v2" "public_ip" {
  pool = "public"
}

resource "openstack_networking_floatingip_v2" "public_ip2" {
  pool = "public"
}

resource "openstack_compute_floatingip_associate_v2" "jumphost" {
  floating_ip = "${openstack_networking_floatingip_v2.public_ip.address}"
  instance_id = "${openstack_compute_instance_v2.master.id}"
}

resource "openstack_compute_floatingip_associate_v2" "node_pub_ip" {
  floating_ip = "${openstack_networking_floatingip_v2.public_ip2.address}"
  instance_id = "${element(openstack_compute_instance_v2.node.*.id, 0)}"
}

## Security groupd for the Kubernetes master
resource "openstack_networking_secgroup_v2" "secgroup_master" {
  name        = "secgroup_nodes"
  description = "Allow  access to the API server"
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

resource "openstack_networking_secgroup_v2" "secgroup_node" {
  name        = "secgroup_nodes"
  description = "Allow network functionality for kubelet"
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_node_rule_ssh" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.secgroup_node.id}"
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

resource "openstack_networking_secgroup_rule_v2" "secgroup_node_rule_nodeport" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 30000
  port_range_max    = 32767
  #remote_group_id   = "${openstack_networking_secgroup_rule_v2.secgroup_master.id}"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.secgroup_node.id}"
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_node_rule_tcp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 1
  port_range_max    = 65535
  #remote_group_id   = "${openstack_networking_secgroup_v2.secgroup_node.id}"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.secgroup_node.id}"
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_node_rule_tcp_egress" {
  direction         = "egress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 1
  port_range_max    = 65535
  #remote_group_id   = "${openstack_networking_secgroup_v2.secgroup_node.id}"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.secgroup_node.id}"
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_node_rule_udp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "udp"
  port_range_min    = 1
  port_range_max    = 65535
  #remote_group_id   = "${openstack_networking_secgroup_v2.secgroup_node.id}"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.secgroup_node.id}"
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_node_rule_udp_egress" {
  direction         = "egress"
  ethertype         = "IPv4"
  protocol          = "udp"
  port_range_min    = 1
  port_range_max    = 65535
  #remote_group_id   = "${openstack_networking_secgroup_v2.secgroup_node.id}"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.secgroup_node.id}"
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_node_rule_ipip_ingress" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = 94
  #remote_group_id   = "${openstack_networking_secgroup_v2.secgroup_node.id}"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.secgroup_node.id}"
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_node_rule_ipip_egress" {
  direction         = "egress"
  ethertype         = "IPv4"
  protocol          = 94
  #remote_group_id   = "${openstack_networking_secgroup_v2.secgroup_node.id}"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.secgroup_node.id}"
}
