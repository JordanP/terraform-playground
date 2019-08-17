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
        container {
          name  = "grafana"
          image = "grafana/grafana:6.3.3"
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
          volume_mount {
            name       = "config"
            mount_path = "/etc/grafana"
          }
          volume_mount {
            name       = "datasources"
            mount_path = "/etc/grafana/provisioning/datasources"
          }
          volume_mount {
            name       = "providers"
            mount_path = "/etc/grafana/provisioning/dashboards"
          }
          volume_mount {
            name       = "dashboards-etcd"
            mount_path = "/etc/grafana/dashboards/_etcd_"
          }
          volume_mount {
            name       = "dashboards-prom"
            mount_path = "/etc/grafana/dashboards/_prom_"
          }
          volume_mount {
            name       = "dashboards-nginx"
            mount_path = "/etc/grafana/dashboards/_nginx_"
          }
          volume_mount {
            name       = "dashboards-k8s"
            mount_path = "/etc/grafana/dashboards/_k8s_"
          }
          volume_mount {
            name       = "dashboards-k8s-nodes"
            mount_path = "/etc/grafana/dashboards/_k8s-nodes_"
          }
          volume_mount {
            name       = "dashboards-k8s-resources"
            mount_path = "/etc/grafana/dashboards/_k8s-resources_"
          }
          volume_mount {
            name       = "dashboards-nodes"
            mount_path = "/etc/grafana/dashboards/_nodes_"
          }
        }
        volume {
          name = "config"
          config_map {
            name = kubernetes_config_map.grafana_config.metadata[0].name
          }
        }
        volume {
          name = "datasources"
          config_map {
            name = kubernetes_config_map.grafana_datasources.metadata[0].name
          }
        }
        volume {
          name = "providers"
          config_map {
            name = kubernetes_config_map.grafana_providers.metadata[0].name
          }
        }
        volume {
          name = "dashboards-etcd"
          config_map {
            name = kubernetes_config_map.grafana_dashboards_etcd.metadata[0].name
          }
        }
        volume {
          name = "dashboards-nginx"
          config_map {
            name = kubernetes_config_map.grafana_dashboards_nginx.metadata[0].name
          }
        }
        volume {
          name = "dashboards-prom"
          config_map {
            name = kubernetes_config_map.grafana_dashboards_prom.metadata[0].name
          }
        }
        volume {
          name = "dashboards-k8s"
          config_map {
            name = kubernetes_config_map.grafana_dashboards_k8s.metadata[0].name
          }
        }
        volume {
          name = "dashboards-k8s-nodes"
          config_map {
            name = kubernetes_config_map.grafana_dashboards_k8s_nodes.metadata[0].name
          }
        }
        volume {
          name = "dashboards-k8s-resources"
          config_map {
            name = kubernetes_config_map.grafana_dashboards_k8s_resources.metadata[0].name
          }
        }
        volume {
          name = "dashboards-nodes"
          config_map {
            name = kubernetes_config_map.grafana_dashboards_nodes.metadata[0].name
          }
        }
      }
    }
  }
}
