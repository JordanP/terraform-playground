resource "kubernetes_service" "prometheus" {
  metadata {
    name      = "prometheus"
    namespace = "${var.namespace}"

    annotations = {
      "prometheus.io/scrape" = "true"
    }
  }

  spec {
    type = "ClusterIP"

    selector {
      name = "prometheus"
    }

    port {
      name        = "web"
      protocol    = "TCP"
      port        = "80"
      target_port = "9090"
    }
  }
}
