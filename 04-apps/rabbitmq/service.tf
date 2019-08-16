resource "kubernetes_service" "rabbitmq" {
  metadata {
    name      = "rabbitmq"
    namespace = kubernetes_namespace.rabbitmq[0].metadata.0.name
  }
  spec {
    cluster_ip = "None"
    selector = {
      app = "rabbitmq"
    }
    port {
      port     = 4369
      name     = "rabbitmq-epmd"
      protocol = "TCP"
    }
    port {
      port     = 5672
      name     = "rabbitmq-amqp"
      protocol = "TCP"
    }
    port {
      port     = 15672
      name     = "rabbitmq-management"
      protocol = "TCP"
    }
    port {
      port     = 25672
      name     = "erlang-distribution"
      protocol = "TCP"
    }
  }
}