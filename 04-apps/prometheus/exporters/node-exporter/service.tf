resource "kubernetes_service" "node_exporter" {
  metadata {
    name      = "node-exporter"
    namespace = var.namespace

    annotations = {
      "prometheus.io/scrape" = "true"
    }
  }

  spec {
    type       = "ClusterIP"
    cluster_ip = "None"

    selector = {
      name = "node-exporter"
    }

    port {
      name        = "metrics"
      protocol    = "TCP"
      port        = "90"
      target_port = "9100"
    }
  }
}
