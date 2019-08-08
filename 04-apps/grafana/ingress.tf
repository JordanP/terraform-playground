resource "kubernetes_ingress" "grafana" {
  metadata {
    name      = "grafana"
    namespace = var.namespace
    annotations = {
      "kubernetes.io/ingress.class"              = "public"
      "nginx.ingress.kubernetes.io/ssl-redirect" = "false"
    }
  }
  spec {
    rule {
      host = var.hostname
      http {
        path {
          backend {
            service_name = kubernetes_service.grafana.metadata.0.name
            service_port = "80"
          }
        }
      }
    }
  }
}