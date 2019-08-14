resource "kubernetes_service" "redis" {
  metadata {
    name = "redis"
    annotations = {
      "prometheus.io/port"   = "9121"
      "prometheus.io/scrape" = "true"
    }
  }
  spec {
    selector = {
      app = "redis"
    }
    type = "ClusterIP"
    port {
      port        = 6379
      target_port = 6379
      protocol    = "TCP"
      name        = "redis"
    }
    port {
      name        = "metrics"
      port        = 9121
      protocol    = "TCP"
      target_port = "metric"
    }
  }
}
