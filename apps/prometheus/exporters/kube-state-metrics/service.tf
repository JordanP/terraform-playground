resource "kubernetes_service" "kube_scheduler" {
  metadata {
    name      = "kube-state-metrics"
    namespace = var.namespace

    annotations = {
      "prometheus.io/scrape" = "true"
    }
  }

  spec {
    type       = "ClusterIP"
    cluster_ip = "None"

    selector = {
      name = "kube-state-metrics"
    }

    port {
      name        = "metrics"
      protocol    = "TCP"
      port        = "8080"
      target_port = "8080"
    }
  }
}
