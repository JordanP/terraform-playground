resource "kubernetes_service" "grafana" {
  "metadata" {
    name      = "grafana"
    namespace = "${kubernetes_namespace.monitoring.metadata.0.name}"

    annotations {
      "prometheus.io/scrape" = "true"
      "prometheus.io/port"   = "10254'"
    }
  }

  "spec" {
    type = "ClusterIP"

    selector {
      name  = "grafana"
      phase = "prod"
    }

    port {
      name        = "http"
      protocol    = "TCP"
      port        = 80
      target_port = "8080"
    }
  }
}
