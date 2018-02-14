output "master_ip" {
  value = "ssh ubuntu@${openstack_networking_floatingip_v2.public_ip.address}"
}
