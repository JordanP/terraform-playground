variable "namespace" {}

resource "kubernetes_service_account" "node_exporter" {
  automount_service_account_token = true
  metadata {
    name      = "node-exporter"
    namespace = var.namespace
  }
}
