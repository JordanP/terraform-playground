resource "kubernetes_namespace" "ingress" {
  count = (var.namespace != "default" ? 1 : 0)
  metadata {
    name = var.namespace
    labels = {
      name = var.namespace
    }
  }
}
