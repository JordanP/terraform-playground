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
          image = "quay.io/coreos/kube-state-metrics:v1.8.0"

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
              port = "8080"
            }

            initial_delay_seconds = 5
            timeout_seconds       = 5
          }

        }

        container {
          name  = "addon-resizer"
          image = "k8s.gcr.io/addon-resizer:1.8.5"

          resources {
            limits {
              cpu    = "100m"
              memory = "30Mi"
            }

            requests {
              cpu    = "100m"
              memory = "30Mi"
            }
          }

          env {
            name = "MY_POD_NAME"

            value_from {
              field_ref {
                field_path = "metadata.name"
              }
            }
          }

          env {
            name = "MY_POD_NAMESPACE"

            value_from {
              field_ref {
                field_path = "metadata.namespace"
              }
            }
          }

          command = [
            "/pod_nanny",
            "--container=kube-state-metrics",
            "--cpu=100m",
            "--extra-cpu=1m",
            "--memory=100Mi",
            "--extra-memory=2Mi",
            "--threshold=5",
            "--deployment=kube-state-metrics",
          ]

        }
      }
    }
  }
}
