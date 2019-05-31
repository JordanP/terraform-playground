resource "kubernetes_deployment" "prometheus" {
  metadata {
    name      = "prometheus"
    namespace = "${var.namespace}"
  }

  spec {
    replicas = 1

    selector {
      match_labels {
        name = "prometheus"
      }
    }

    template {
      metadata {
        labels {
          name = "prometheus"
        }

        /*annotations {
          "seccomp.security.alpha.kubernetes.io/pod" = "docker/default"
        }*/
      }

      spec {
        service_account_name = "${module.prometheus_rbac.service_account_name}"

        container {
          name  = "prometheus"
          image = "quay.io/prometheus/prometheus:v2.10.0"

          args = [
            "--web.listen-address=0.0.0.0:9090",
            "--config.file=/etc/prometheus/prometheus.yaml",
            "--storage.tsdb.path=/var/lib/prometheus",
          ]

          port {
            name           = "web"
            container_port = 9090
          }

          resources {
            requests {
              cpu    = "100m"
              memory = "200Mi"
            }
          }

          volume_mount {
            name       = "config"
            mount_path = "/etc/prometheus"
          }

          volume_mount {
            name       = "rules"
            mount_path = "/etc/prometheus/rules"
          }

          volume_mount {
            name       = "data"
            mount_path = "/var/lib/prometheus"
          }

          volume_mount {
            mount_path = "/var/run/secrets/kubernetes.io/serviceaccount"
            name       = "${module.prometheus_rbac.service_account_default_secret_name}"
            read_only  = true
          }

          liveness_probe {
            http_get {
              path = "/-/healthy"
              port = "9090"
            }

            initial_delay_seconds = 10
            timeout_seconds       = 10
          }

          readiness_probe {
            http_get {
              path = "/-/healthy"
              port = "9090"
            }

            initial_delay_seconds = 10
            timeout_seconds       = 10
          }
        }

        termination_grace_period_seconds = 30

        volume {
          name = "${module.prometheus_rbac.service_account_default_secret_name}"

          secret {
            secret_name = "${module.prometheus_rbac.service_account_default_secret_name}"
          }
        }

        volume {
          name = "config"

          config_map {
            name = "${kubernetes_config_map.prometheus_config.metadata.0.name}"
          }
        }

        volume {
          name = "rules"

          config_map {
            name = "${kubernetes_config_map.prometheus_rules.metadata.0.name}"
          }
        }

        volume {
          name      = "data"
          empty_dir = {}
        }
      }
    }
  }
}
