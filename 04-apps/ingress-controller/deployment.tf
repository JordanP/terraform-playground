resource "kubernetes_config_map" "tcp_services" {
  metadata {
    name      = "tcp-services"
    namespace = kubernetes_namespace.ingress.metadata[0].name
  }

  data = {
    "8022" = "gitlab-ce/${var.gitlab_release_name}-gitlab-shell:22"
  }
}

resource "kubernetes_deployment" "ingress" {
  metadata {
    name      = "nginx-ingress-controller"
    namespace = kubernetes_namespace.ingress.metadata[0].name
  }

  spec {
    replicas = 3

    strategy {
      rolling_update {
        max_unavailable = 1
      }
    }

    selector {
      match_labels = {
        name = "nginx-ingress-controller"
      }
    }

    template {
      metadata {
        labels = {
          name = "nginx-ingress-controller"
        }

        /*annotations = {
          "seccomp.security.alpha.kubernetes.io/pod" = "docker/default"
        }*/
      }

      spec {
        service_account_name            = kubernetes_service_account.ingress.metadata[0].name
        automount_service_account_token = true
        node_selector = {
          "node-role.kubernetes.io/node" = ""
        }

        container {
          name  = "nginx-ingress-controller"
          image = "quay.io/kubernetes-ingress-controller/nginx-ingress-controller:0.25.0"

          args = [
            "/nginx-ingress-controller",
            "--ingress-class=public",
            "--tcp-services-configmap=$(POD_NAMESPACE)/tcp-services",
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

          port {
            container_port = 8022
            host_port      = 8022
            name           = "proxied-ssh"
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
        }
        restart_policy                   = "Always"
        termination_grace_period_seconds = 60
      }
    }
  }
}
