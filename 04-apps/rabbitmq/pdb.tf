resource "kubernetes_pod_disruption_budget" "default" {
  metadata {
    name      = "rabbitmq"
    namespace = (var.namespace != "default" ? kubernetes_namespace.rabbitmq[0].metadata.0.name : "default")
    labels = {
      app = "rabbitmq"
    }
  }
  spec {
    max_unavailable = 1
    selector {
      match_labels = {
        app = "rabbitmq"
      }
    }
  }
}
