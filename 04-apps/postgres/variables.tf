variable "namespace" {
  default = "default"
}

variable "image" {}
variable "replica_count" {}
variable "disk_size" {}
variable "disk_type" {
  default = "ssd"
}

variable "primary_node_selector" {
  type = map(string)
  default = {
    node_type = "standard"
  }
}
variable "resources" {
  type = object({
    cpu    = string
    memory = string
  })
  default = {
    cpu    = "500m"
    memory = "768Mi"
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
variable "postgresql_primary_effective_cache_size" {}
variable "postgresql_primary_shared_buffers" {}
variable "postgresql_primary_maintenance_work_mem" {}
variable "postgresql_replica_max_connections" {}
variable "postgresql_replica_work_mem" {}
variable "postgresql_replica_effective_cache_size" {}
variable "postgresql_replica_shared_buffers" {}
variable "postgresql_replica_maintenance_work_mem" {}
