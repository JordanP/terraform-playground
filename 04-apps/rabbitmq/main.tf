resource "kubernetes_namespace" "rabbitmq" {
  count = (var.namespace != "default" ? 1 : 0)
  metadata {
    name = var.namespace
  }
}