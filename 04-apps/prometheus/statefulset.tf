resource "kubernetes_stateful_set" "prometheus" {
  metadata {
    name      = "prometheus"
    namespace = var.namespace
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        name = "prometheus"
      }
    }
    update_strategy {
      type = "RollingUpdate"
      rolling_update {
        partition = 0
      }
    }
    template {
      metadata {
        labels = {
          name = "prometheus"
        }
        /*annotations = {
          "seccomp.security.alpha.kubernetes.io/pod" = "docker/default"
        }*/
      }
      spec {
        service_account_name            = module.prometheus_rbac.service_account_name
        automount_service_account_token = true
        init_container {
          name    = "init-chown-data"
          image   = "busybox"
          command = ["chown", "-R", "65534:65534", "/var/lib/prometheus"]
          volume_mount {
            name       = "prometheus-data"
            mount_path = "/var/lib/prometheus"
          }
        }
        container {
          name  = "prometheus"
          image = "quay.io/prometheus/prometheus:v2.19.1"
          args = [
            "--web.listen-address=0.0.0.0:9090",
            "--config.file=/etc/prometheus/prometheus.yaml",
            "--storage.tsdb.path=/var/lib/prometheus",
            "--storage.tsdb.retention.time=15d"
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
            name       = "prometheus-data"
            mount_path = "/var/lib/prometheus"
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
          name = module.prometheus_rbac.service_account_default_secret_name
          secret {
            secret_name = module.prometheus_rbac.service_account_default_secret_name
          }
        }
        volume {
          name = "config"
          config_map {
            name = kubernetes_config_map.prometheus_config.metadata[0].name
          }
        }
        volume {
          name = "rules"
          config_map {
            name = kubernetes_config_map.prometheus_rules.metadata[0].name
          }
        }
      }
    }
    service_name = "prometheus"
    volume_claim_template {
      metadata {
        name = "prometheus-data"
      }
      spec {
        access_modes = ["ReadWriteOnce"]
        resources {
          requests = {
            storage = "200Gi"
          }
        }
      }
    }
  }
}
