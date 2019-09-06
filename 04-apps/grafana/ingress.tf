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
    "tls.crt" = sha256(var.tls_certificate)
    "tls.key" = sha256(var.tls_private_key)
  }
}

resource "kubernetes_secret" "wildcard_certificate" {
  metadata {
    namespace = var.namespace
    name      = "wildcard-jordanpittier-net-${random_id.wildcard_certificate_name_suffix.hex}"
  }

  type = "kubernetes.io/tls"

  data = {
    "tls.crt" = var.tls_certificate
    "tls.key" = var.tls_private_key
  }
}
