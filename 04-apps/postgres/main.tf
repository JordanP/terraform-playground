resource "kubernetes_namespace" "postgresql" {
  count = (var.namespace != "default" ? 1 : 0)
  metadata {
    name = var.namespace
  }
}
