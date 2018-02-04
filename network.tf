### Inital VPC setup
resource "openstack_networking_network_v2" "private" {
  name           = "private"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "subnet_private" {
  name       = "subnet_private"
  network_id = "${openstack_networking_network_v2.private.id}"
  cidr       = "172.16.0.0/12"
  ip_version = 4
}

data "openstack_networking_network_v2" "public" {
  name = "public"
}

resource "openstack_networking_router_v2" "private_router" {
  name             = "private_router"
  external_gateway = "${data.openstack_networking_network_v2.public.id}"
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
resource "openstack_compute_secgroup_v2" "secgroup_master" {
  name        = "secgroup_master"
  description = "Allow access to the API server"
  # Allow access to the secure Kubernetes API
  rule {
    from_port   = 6443
    to_port     = 6443
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

  # Since we currently don't have a HA setup keep etcd secure
  # 2379-2380 etcd server client API
}

# Security group for the Kubernetes nodes
resource "openstack_compute_secgroup_v2" "secgroup_node" {
  name        = "secgroup_nodes"
  description = "Allow ICMP and ssh"

  # Allow SSH
  rule {
    from_port   = 22
    to_port     = 22
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

  # Allow ICMP
  rule {
    from_port   = -1
    to_port     = -1
    ip_protocol = "icmp"
    cidr        = "0.0.0.0/0"
  }

  # Kubelet API
  rule {
    from_port   = 10250
    to_port     = 10250
    ip_protocol = "tcp"
    from_group_id = "${openstack_compute_secgroup_v2.secgroup_master.id}"
  }

  # Read-only Kubelet API (Heapster)
  rule {
    from_port   = 10255
    to_port     = 10255
    ip_protocol = "tcp"
    from_group_id = "${openstack_compute_secgroup_v2.secgroup_master.id}"
  }

  # Default range for NodePort services
  rule {
    from_port   = 30000
    to_port     = 32767
    ip_protocol = "tcp"
    # TODO this should be limited to the LoadBalancer
    cidr        = "0.0.0.0/0"
  }
}
