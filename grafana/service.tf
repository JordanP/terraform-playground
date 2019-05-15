resource "kubernetes_service" "grafana" {
  metadata {
    name      = "grafana"
    namespace = "${var.namespace}"

    annotations = {
      "prometheus.io/scrape" = "true"
      "prometheus.io/port"   = "10254'"
    }
  }

  spec {
    type = "ClusterIP"

    selector {
      name = "grafana"
    }

    port {
      name        = "http"
      protocol    = "TCP"
      port        = 80
      target_port = "8080"
    }
  }
}
