variable username {
  type = "string"
}

variable password {
  type = "string"
}

variable domain_name {
  # https://www.terraform.io/docs/providers/openstack/#domain_name
  type = "string"
}

variable user_domain_name {
  # https://www.terraform.io/docs/providers/openstack/#user_domain_name
  type    = "string"
  default = ""
}

variable tenant_name {
  # https://www.terraform.io/docs/providers/openstack/#tenant_name
  type = "string"
}

variable project_id {
  type = "string"
}

variable image_name {
  type = "string"
}

variable auth_url {
  type = "string"
}

variable ssh_pub_key {
  type    = "string"
  default = "~/.ssh/id_rsa.pub"
}

variable region {
  type    = "string"
  default = "fra"
}

variable flavor {
  type    = "string"
  default = "c4.large"
}

variable cluster_name {
  type = "string"
}

variable node_count {
  type    = "string"
  default = 1
}

variable kubernetes_version {
  type    = "string"
  default = "1.13.2"
}

variable pod_subnet {
  type    = "string"
  default = "192.168.0.0/16"
}

# Must match: "[a-z0-9]{6}.[a-z0-9]{16}"
variable bootstrap_token {
  type    = "string"
  default = ""
}

variable containerd_version {
  type = "string"
}

variable cluster_network_node_cidr {
  type    = "string"
  default = "172.16.0.0/16"
}

variable "cluster_network_router_id" {
  description = "The cluster private node network will be attached to this router"
  type        = "string"
}
