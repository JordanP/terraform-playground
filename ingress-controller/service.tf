resource "kubernetes_service" "ingress" {
  metadata {
    name      = "nginx-ingress-controller"
    namespace = "${var.namespace}"

    annotations {
      "prometheus.io/scrape" = "true"
      "prometheus.io/port"   = "10254'"
    }
  }

  spec {
    type = "ClusterIP"

    selector {
      name  = "nginx-ingress-controller"
      phase = "prod"
    }

    port {
      name        = "http"
      protocol    = "TCP"
      port        = 80
      target_port = "80"
    }

    port {
      name        = "https"
      protocol    = "TCP"
      port        = 443
      target_port = "443"
    }
  }
}
