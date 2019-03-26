variable username {
  description = "OpenStack username used by cluster controller manager components to authenticate to the OpenStack API"
  type        = "string"
}

variable password {
  description = "OpenStack password used by cluster controller manager components to authenticate to the OpenStack API"
  type        = "string"
}

variable domain_name {
  # https://www.terraform.io/docs/providers/openstack/#domain_name
  description = "The OpenStack domain name of the project, this cluster lives in"
  type        = "string"
}

variable user_domain_name {
  # https://www.terraform.io/docs/providers/openstack/#user_domain_name
  description = "The OpenStack domain name of the username, this cluster lives in"
  type        = "string"
  default     = ""
}

variable tenant_name {
  # https://www.terraform.io/docs/providers/openstack/#tenant_name
  description = "The OpenStack project name this cluster lives in"
  type        = "string"
}

variable project_id {
  description = "The ID of the OpenStack project this cluster lives in"
  type        = "string"
}

variable auth_url {
  description = "The URL of the keystone authentication endpoint"
  type        = "string"
}

variable ssh_pub_key {
  description = "The ssh public key used for SSH session of the user"
  type        = "string"
  default     = "~/.ssh/id_rsa.pub"
}

variable region {
  description = "The name of the OpenStack region this cluster will live in"
  type        = "string"
  default     = "fra"
}

variable flavor {
  description = "The OpenStack instance flavor used for nodes and the master"
  type        = "string"
  default     = "c4.large"
}

variable cluster_name {
  description = "The name of the cluster"
  type        = "string"
}

variable node_count {
  description = "The number of nodes deployed into that cluster"
  type        = "string"
  default     = 1
}

variable kubernetes_version {
  description = "The deployed kubernetes version"
  type        = "string"
  default     = "1.13.2"
}

variable kubernetes_cni_version {
  description = "The deployed kubernetes cni version"
  type        = "string"
  default     = "0.6.0"
}

variable pod_subnet {
  description = "The CIDR used for the pod network"
  type        = "string"
  default     = "192.168.0.0/16"
}

# Must match: "[a-z0-9]{6}.[a-z0-9]{16}"
variable bootstrap_token {
  description = "The bootstrap token used for the kubeadm join. If not set, this token will be generated at random"
  type        = "string"
  default     = ""
}

variable containerd_version {
  description = "The version of the installed containerd daemon"
  type        = "string"
  default     = "1.2.4"
}

variable cluster_network_node_cidr {
  description = "The CIDR for the OpenStack network of the cluster nodes"
  type        = "string"
  default     = "172.16.0.0/16"
}

variable "cluster_network_router_id" {
  description = "The cluster private node network will be attached to this router"
  type        = "string"
}

variable "master_data_volume_size" {
  description = "The size of the data disk of the master node"
  type        = "string"
  default     = "15"
}

variable "node_data_volume_size" {
  description = "The size of the data disk of the worker node"
  type        = "string"
  default     = "15"
}

variable "public_network_name" {
  description = "The name of your available public network"
  type        = "string"
  default     = "public"
}

variable "image_visibility" {
  description = "Visiblity of the used Image"
  type        = "string"
  default     = "public"
}