variable "namespace" {
  default = "default"
}

variable "image" {}
variable "replica_count" {}
variable "disk_size" {}
variable "disk_type" {
  default = "standard"
}

variable "node_selector" {
  type = map(string)
  default = {
    node_type = "standard"
  }
}