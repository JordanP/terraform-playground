resource "kubernetes_service_account" "prometheus" {
  automount_service_account_token = true
  metadata {
    name      = "prometheus"
    namespace = var.namespace
  }
}
