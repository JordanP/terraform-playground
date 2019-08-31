resource "kubernetes_service_account" "postgres" {
  metadata {
    name      = "postgres"
    namespace = (var.namespace != "default" ? kubernetes_namespace.postgresql[0].metadata.0.name : "default")
  }
  automount_service_account_token = true
}