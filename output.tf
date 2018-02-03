output "floating_ip" {
  value = "ssh ubuntu@${openstack_networking_floatingip_v2.public_ip.address}"
}

# ONLY for TESTING!
output "floating_ip2" {
  value = "ssh ubuntu@${openstack_networking_floatingip_v2.public_ip2.address}"
}
