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
    node_type = "standard"
  }
}

variable "replica_node_selector" {
  type = map(string)
  default = {
    node_type = "standard"
  }
}

variable "postgresql_conf_template" {}
variable "postgresql_primary_max_connections" {}
variable "postgresql_primary_work_mem" {}
variable "postgresql_replica_max_connections" {}
variable "postgresql_replica_work_mem" {}