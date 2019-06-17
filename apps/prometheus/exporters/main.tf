variable "namespace" {}

module "node_exporter" {
  source    = "./node-exporter"
  namespace = var.namespace
}

module "kube_state_metrics" {
  source    = "./kube-state-metrics"
  namespace = var.namespace
}
