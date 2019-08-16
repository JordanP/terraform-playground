variable "namespace" {
  default = "default"
}

variable "replica_count" {
  default = 3
}

variable "disk_type" {
  default = "standard"
}

variable "disk_size" {}

variable "image" {}

variable "node_selector" {
  type = map(string)
  default = {
    node_type = "rabbitmq"
  }
}