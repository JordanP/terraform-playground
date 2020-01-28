variable "namespace" {}

resource "kubernetes_deployment" "kube_state_metrics" {
  metadata {
    name      = "kube-state-metrics"
    namespace = var.namespace
    labels = {
      name = "kube-state-metrics"
    }
  }

  spec {
    replicas = "1"

    strategy {
      type = "RollingUpdate"
    }

    selector {
      match_labels = {
        name = "kube-state-metrics"
      }
    }

    template {
      metadata {
        labels = {
          name = "kube-state-metrics"
        }
      }

      spec {
        service_account_name            = kubernetes_service_account.kube_state_metrics.metadata[0].name
        automount_service_account_token = true
        container {
          name  = "kube-state-metrics"
          image = "quay.io/coreos/kube-state-metrics:v1.9.3"

          port {
            name           = "metrics"
            container_port = "8080"
          }

          readiness_probe {
            http_get {
              path = "/healthz"
              port = "8080"
            }

            initial_delay_seconds = 5
            timeout_seconds       = 5
          }

          liveness_probe {
            http_get {
              path = "/healthz"
              port = "8081"
            }

            initial_delay_seconds = 5
            timeout_seconds       = 5
          }

        }

      }
    }
  }
}
