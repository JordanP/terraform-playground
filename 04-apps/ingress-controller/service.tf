resource "kubernetes_service" "ingress" {
  metadata {
    name      = "nginx-ingress-controller"
    namespace = (var.namespace != "default" ? kubernetes_namespace.ingress[0].metadata.0.name : "default")
    annotations = {
      "prometheus.io/scrape" = "true"
      "prometheus.io/port"   = "10254"
    }
  }
  spec {
    type = "ClusterIP"
    selector = {
      name = "nginx-ingress-controller"
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
