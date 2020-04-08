resource "kubernetes_deployment" "ingress" {
  metadata {
    name      = "nginx-ingress-controller"
    namespace = (var.namespace != "default" ? kubernetes_namespace.ingress[0].metadata.0.name : "default")
  }
  spec {
    replicas = 2
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
        node_selector                   = var.node_selector
        container {
          name  = "nginx-ingress-controller"
          image = "quay.io/kubernetes-ingress-controller/nginx-ingress-controller:0.30.0"
          args = [
            "/nginx-ingress-controller",
            "--configmap=$(POD_NAMESPACE)/${kubernetes_config_map.nginx_configuration.metadata.0.name}",
            "--ingress-class=public",
            "--tcp-services-configmap=$(POD_NAMESPACE)/${kubernetes_config_map.tcp_services.metadata.0.name}",
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
          lifecycle {
            pre_stop {
              exec {
                command = ["/wait-shutdown"]
              }
            }
          }
          security_context {
            capabilities {
              add  = ["NET_BIND_SERVICE", ]
              drop = ["ALL", ]
            }
            run_as_user = 101
          }
        }
        termination_grace_period_seconds = 300
      }
    }
  }
  depends_on = [kubernetes_config_map.nginx_configuration]
}
