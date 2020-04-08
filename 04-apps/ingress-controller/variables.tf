variable "namespace" {
  default = "ingress"
}
variable "node_selector" {
  type = map(string)
  default = {
    node_type = "standard"
  }
}
variable "gitlab_release_name" {}
