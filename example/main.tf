# Fetch the public network. The router will be attached to this network
data "openstack_networking_network_v2" "public" {
  name = "public"
}

# Fetch project metadata from current authentication session
data "openstack_identity_auth_scope_v3" "scope" {
  name = "my_scope" # This name must be a project unique value. It can be choosen at your will.
}

# This router is used to link the cluster network to the public network. If you want to attach the kubernetes cluster
# network to an existing router, use that router instead of creating this one.
resource "openstack_networking_router_v2" "router" {
  name                = "router"
  admin_state_up      = "true"
  external_network_id = "${data.openstack_networking_network_v2.public.id}"
}

# Create the kubernetes cluster.
module "my_cluster" {
  source = "../"

  auth_url         = "${var.auth_url}"
  cluster_name     = "example-cluster"
  username         = "${var.username}"
  password         = "${var.password}"
  domain_name      = "${data.openstack_identity_auth_scope_v3.scope.project_domain_name}"
  user_domain_name = "${data.openstack_identity_auth_scope_v3.scope.user_domain_name}"
  tenant_name      = "${data.openstack_identity_auth_scope_v3.scope.project_name}"

  project_id = "${data.openstack_identity_auth_scope_v3.scope.project_id}"

  kubernetes_version        = "1.13.2"
  kubernetes_cni_version    = "0.6.0"
  containerd_version        = "1.2.4"
  cluster_network_router_id = "${openstack_networking_router_v2.router.id}"
  node_count                = "2"
  flavor                    = "c4.medium"
  master_data_volume_size   = "15"
  node_data_volume_size     = "15"
}

# Generate the kubeconfig to access this cluster
resource "local_file" "kubeconfig" {
  content  = "${module.my_cluster.kubeconfig}"
  filename = "${path.module}/kubeconfig"
}
