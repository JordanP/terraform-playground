resource "kubernetes_ingress" "grafana" {
  metadata {
    name      = "grafana"
    namespace = var.namespace
    annotations = {
      "kubernetes.io/ingress.class"              = "public"
      "nginx.ingress.kubernetes.io/ssl-redirect" = "true"
    }
  }
  spec {
    tls {
      secret_name = kubernetes_secret.wildcard_certificate.metadata.0.name
    }
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

resource "random_id" "wildcard_certificate_name_suffix" {
  byte_length = 4

  keepers = {
    "tls.crt" = base64sha256(file("${path.module}/../certs/jordanpittier.net.cer"))
    "tls.key" = base64sha256(file("${path.module}/../certs/jordanpittier.net.key"))
  }
}

resource "kubernetes_secret" "wildcard_certificate" {
  metadata {
    namespace = var.namespace
    name      = "wildcard-jordanpittier-net-${random_id.wildcard_certificate_name_suffix.hex}"
  }

  type = "kubernetes.io/tls"

  data = {
    "tls.crt" = file("${path.module}/../certs/jordanpittier.net.cer")
    "tls.key" = file("${path.module}/../certs/jordanpittier.net.key")
  }
}
