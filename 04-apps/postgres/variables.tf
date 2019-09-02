variable "namespace" {
  default = "default"
}

variable "image" {}
variable "replica_count" {}
variable "disk_size" {}
variable "disk_type" {
  default = "ssd"
}

variable "master_node_selector" {
  type = map(string)
  default = {
    node_type = "pg-master"
  }
}

variable "replica_node_selector" {
  type = map(string)
  default = {
    node_type = "pg-replica"
  }
}

variable "postgresql_conf" {}