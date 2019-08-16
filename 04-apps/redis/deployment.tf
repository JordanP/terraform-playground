resource "kubernetes_deployment" "redis" {
  metadata {
    name = "redis"
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "redis"
      }
    }
    template {
      metadata {
        labels = {
          app = "redis"
        }
      }
      spec {
        security_context {
          # https://github.com/docker-library/redis/blob/0b2910f292fa6ac32318cb2acc84355b11aa8a7a/5.0/alpine/Dockerfile#L4
          run_as_user = 999
          fs_group    = 1000
        }
        init_container {
          name  = "set-somaxconn"
          image = "busybox:latest"
          security_context {
            privileged = true
          }
          # See what http://download.redis.io/redis-stable/redis.conf says about tcp-backlog
          # Without this, Redis complains at startup with
          # The TCP backlog setting of 511 cannot be enforced because /proc/sys/net/core/somaxconn is set to the lower value of 128
          command = ["sh", "-c", "sysctl -w net.core.somaxconn=1024"]
        }
        init_container {
          name    = "configure"
          image   = "busybox:latest"
          command = ["sh", "/configmap/configure.sh"]
          security_context {
            allow_privilege_escalation = false
          }
          volume_mount {
            mount_path = "/configmap"
            name       = "configmap"
            read_only  = true
          }
          volume_mount {
            mount_path = "/etc/redis"
            name       = "redis-config"
          }
          env {
            name = "REDIS_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.redis_password.metadata.0.name
                key  = "password"
              }
            }
          }
        }
        container {
          name  = "redis"
          image = "redis:5.0-alpine"
          port {
            container_port = 6379
            name           = "redis"
          }
          args = ["redis-server", "/etc/redis/redis.conf"]
          env {
            name = "REDIS_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.redis_password.metadata.0.name
                key  = "password"
              }
            }
          }
          volume_mount {
            mount_path = "/etc/redis"
            name       = "redis-config"
            read_only  = true
          }
          volume_mount {
            mount_path = "/data/redis"
            name       = "redis-data"
          }
          liveness_probe {
            initial_delay_seconds = 5
            period_seconds        = 5
            timeout_seconds       = 1
            success_threshold     = 1
            failure_threshold     = 5
            exec {
              command = ["redis-cli", "-a", "$REDIS_PASSWORD", "ping"]
            }
          }
          readiness_probe {
            initial_delay_seconds = 5
            period_seconds        = 5
            timeout_seconds       = 5
            success_threshold     = 1
            failure_threshold     = 5
            exec {
              command = ["redis-cli", "-a", "$REDIS_PASSWORD", "ping"]
            }
          }
        }
        container {
          name  = "metrics"
          image = "oliver006/redis_exporter:latest"
          env {
            name = "REDIS_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.redis_password.metadata.0.name
                key  = "password"
              }
            }
          }
          port {
            name           = "metrics"
            container_port = 9121
          }
        }
        volume {
          name = "redis-config"
          empty_dir {
            medium = "Memory"
          }
        }
        volume {
          name = "configmap"
          config_map {
            name = kubernetes_config_map.redis_config.metadata.0.name
          }
        }
        volume {
          name = "redis-data"
          empty_dir {}
        }
      }
    }
  }
}
