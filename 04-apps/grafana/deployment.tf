locals {
  volumes = [
    {
      name       = "config"
      mount_path = "/etc/grafana"
      config_map = kubernetes_config_map.grafana_config.metadata[0].name
    },
    {
      name       = "datasources"
      mount_path = "/etc/grafana/provisioning/datasources"
      config_map = kubernetes_config_map.grafana_datasources.metadata[0].name
    },
    {
      name       = "providers"
      mount_path = "/etc/grafana/provisioning/dashboards"
      config_map = kubernetes_config_map.grafana_providers.metadata[0].name
    },
    {
      name       = "dashboards-etcd"
      mount_path = "/etc/grafana/dashboards/etcd"
      config_map = kubernetes_config_map.grafana_dashboards_etcd.metadata[0].name
    },
    {
      name       = "dashboards-redis"
      mount_path = "/etc/grafana/dashboards/redis"
      config_map = kubernetes_config_map.grafana_dashboards_redis.metadata[0].name
    },
    {
      name       = "dashboards-prom"
      mount_path = "/etc/grafana/dashboards/prom"
      config_map = kubernetes_config_map.grafana_dashboards_prom.metadata[0].name
    },
    {
      name       = "dashboards-nginx"
      mount_path = "/etc/grafana/dashboards/nginx"
      config_map = kubernetes_config_map.grafana_dashboards_nginx.metadata[0].name
    },
    {
      name       = "dashboards-k8s"
      mount_path = "/etc/grafana/dashboards/k8s"
      config_map = kubernetes_config_map.grafana_dashboards_k8s.metadata[0].name
    },
    {
      name       = "dashboards-k8s-nodes"
      mount_path = "/etc/grafana/dashboards/k8s-nodes"
      config_map = kubernetes_config_map.grafana_dashboards_k8s_nodes.metadata[0].name
    },
    {
      name       = "dashboards-k8s-resources-1"
      mount_path = "/etc/grafana/dashboards/k8s-resources-1"
      config_map = kubernetes_config_map.grafana_dashboards_k8s_resources_1.metadata[0].name
    },
    {
      name       = "dashboards-k8s-resources-2"
      mount_path = "/etc/grafana/dashboards/k8s-resources-2"
      config_map = kubernetes_config_map.grafana_dashboards_k8s_resources_2.metadata[0].name
    },
    {
      name       = "dashboards-node-exporter"
      mount_path = "/etc/grafana/dashboards/node-exporter"
      config_map = kubernetes_config_map.grafana_dashboards_nodes.metadata[0].name
    }
  ]
}

resource "kubernetes_deployment" "grafana" {
  metadata {
    name      = "grafana"
    namespace = var.namespace
  }
  spec {
    replicas = 1
    strategy {
      rolling_update {
        max_unavailable = "1"
      }
    }
    selector {
      match_labels = {
        name = "grafana"
      }
    }
    template {
      metadata {
        labels = {
          name = "grafana"
        }
        /*annotations = {
          "seccomp.security.alpha.kubernetes.io/pod" = "docker/default"
        }*/
      }
      spec {
        service_account_name = kubernetes_service_account.grafana.metadata.0.name
        container {
          name  = "grafana"
          image = "grafana/grafana:6.6.1"
          env {
            name  = "GF_PATHS_CONFIG"
            value = "/etc/grafana/custom.ini"
          }
          env {
            name  = "GF_SECURITY_ADMIN_USER"
            value = "admin"
          }
          env {
            name = "GF_SECURITY_ADMIN_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.grafana_initial_admin_password.metadata[0].name
                key  = "grafana-admin-password"
              }
            }
          }
          port {
            name           = "http"
            container_port = 8080
          }
          liveness_probe {
            http_get {
              path = "/metrics"
              port = "8080"
            }
            initial_delay_seconds = 10
          }
          readiness_probe {
            http_get {
              path = "/api/health"
              port = "8080"
            }
            initial_delay_seconds = 10
          }
          resources {
            requests {
              cpu    = "100m"
              memory = "100Mi"
            }
            limits {
              cpu    = "200m"
              memory = "200Mi"
            }
          }
          dynamic "volume_mount" {
            for_each = local.volumes
            content {
              name       = volume_mount.value.name
              mount_path = volume_mount.value.mount_path
            }
          }
        }
        dynamic "volume" {
          for_each = local.volumes
          content {
            name = volume.value.name
            config_map {
              name = volume.value.config_map
            }
          }
        }
      }
    }
  }
}
