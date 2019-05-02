resource "kubernetes_deployment" "ingress" {
  metadata {
    name      = "nginx-ingress-controller"
    namespace = "${kubernetes_namespace.ingress.metadata.0.name}"
  }

  spec {
    replicas = 2

    strategy {
      rolling_update {
        max_unavailable = 1
      }
    }

    selector {
      match_labels {
        name = "nginx-ingress-controller"
      }
    }

    template {
      metadata {
        labels {
          name = "nginx-ingress-controller"
        }

        /*annotations {
          "seccomp.security.alpha.kubernetes.io/pod" = "docker/default"
        }*/
      }

      spec {
        service_account_name = "${kubernetes_service_account.ingress.metadata.0.name}"

        node_selector {
          "node-role.kubernetes.io/node" = ""
        }

        container {
          name  = "nginx-ingress-controller"
          image = "quay.io/kubernetes-ingress-controller/nginx-ingress-controller:0.24.1"

          args = [
            "/nginx-ingress-controller",
            "--ingress-class=public",
          ]

          env {
            name = "POD_NAME"

            value_from {
              field_ref {
                field_path = "metadata.name"
              }
            }
          }

          env {
            name = "POD_NAMESPACE"

            value_from {
              field_ref {
                field_path = "metadata.namespace"
              }
            }
          }

          port {
            container_port = 80
            host_port      = 80
            name           = "http"
          }

          port {
            container_port = 443
            host_port      = 443
            name           = "https"
          }

          port {
            container_port = 10254
            host_port      = 10254
            name           = "health"
          }

          liveness_probe {
            failure_threshold = 3

            http_get {
              path   = "/healthz"
              port   = "10254"
              scheme = "HTTP"
            }

            initial_delay_seconds = 10
            period_seconds        = 10
            success_threshold     = 1
            timeout_seconds       = 5
          }

          readiness_probe {
            failure_threshold = 3

            http_get {
              path   = "/healthz"
              port   = "10254"
              scheme = "HTTP"
            }

            period_seconds    = 10
            success_threshold = 1
            timeout_seconds   = 5
          }

          security_context {
            capabilities {
              add = [
                "NET_BIND_SERVICE",
              ]

              drop = [
                "ALL",
              ]
            }

            run_as_user = 33
          }

          volume_mount {
            mount_path = "/var/run/secrets/kubernetes.io/serviceaccount"
            name       = "${kubernetes_service_account.ingress.default_secret_name}"
            read_only  = true
          }
        }

        volume {
          name = "${kubernetes_service_account.ingress.default_secret_name}"

          secret {
            secret_name = "${kubernetes_service_account.ingress.default_secret_name}"
          }
        }

        restart_policy                   = "Always"
        termination_grace_period_seconds = 60
      }
    }
  }
}
