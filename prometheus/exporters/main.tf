variable "namespace" {}

module "node_exporter" {
  source    = "./node-exporter"
  namespace = "${var.namespace}"
}
