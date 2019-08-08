variable "namespace" {}

resource "kubernetes_service_account" "node_exporter" {
  metadata {
    name      = "node-exporter"
    namespace = var.namespace
  }
}
