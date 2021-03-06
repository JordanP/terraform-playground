resource "kubernetes_daemonset" "node_exporter" {
  metadata {
    name      = "node-exporter"
    namespace = var.namespace
  }

  spec {
    strategy {
      type = "RollingUpdate"

      rolling_update {
        max_unavailable = 1
      }
    }

    selector {
      match_labels = {
        name = "node-exporter"
      }
    }

    template {
      metadata {
        labels = {
          name = "node-exporter"
        }
      }

      spec {
        service_account_name            = kubernetes_service_account.node_exporter.metadata[0].name
        automount_service_account_token = true
        security_context {
          run_as_non_root = "true"
          run_as_user     = "65534"
        }

        host_network = "true"
        host_pid     = "true"

        container {
          name  = "node-exporter"
          image = "quay.io/prometheus/node-exporter:v1.0.1"

          args = [
            "--path.procfs=/host/proc",
            "--path.sysfs=/host/sys",
            "--path.rootfs=/host/root",
            "--collector.filesystem.ignored-mount-points=^/(dev|proc|sys|var/lib/docker/.+)($|/)",
            "--collector.filesystem.ignored-fs-types=^(autofs|binfmt_misc|cgroup|configfs|debugfs|devpts|devtmpfs|fusectl|hugetlbfs|mqueue|overlay|proc|procfs|pstore|rpc_pipefs|securityfs|sysfs|tracefs)$",
          ]

          port {
            name           = "metrics"
            container_port = "9100"
            host_port      = "9100"
          }

          resources {
            requests {
              cpu    = "100m"
              memory = "50Mi"
            }

            limits {
              cpu    = "200m"
              memory = "100Mi"
            }
          }

          volume_mount {
            name       = "proc"
            mount_path = "/host/proc"
            read_only  = "true"
          }

          volume_mount {
            name       = "sys"
            mount_path = "/host/sys"
            read_only  = "true"
          }

          volume_mount {
            name       = "root"
            mount_path = "/host/root"
            read_only  = "true"
          }
        }
        toleration {
          key      = "node-role.kubernetes.io/master"
          operator = "Exists"
        }
        toleration {
          key      = "node.kubernetes.io/not-ready"
          operator = "Exists"
        }

        volume {
          name = "proc"

          host_path {
            path = "/proc"
          }
        }

        volume {
          name = "sys"

          host_path {
            path = "/sys"
          }
        }

        volume {
          name = "root"

          host_path {
            path = "/"
          }
        }
      }
    }
  }
}
