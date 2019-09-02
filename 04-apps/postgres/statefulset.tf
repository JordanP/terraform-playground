resource "kubernetes_stateful_set" "postgres_master" {
  metadata {
    labels = {
      app = "postgresql"
    }
    name      = "pg-master"
    namespace = (var.namespace != "default" ? kubernetes_namespace.postgresql[0].metadata.0.name : "default")
  }
  spec {
    replicas = "1"
    selector {
      match_labels = {
        app  = "postgresql"
        role = "master"
      }
    }
    service_name = kubernetes_service.postgres_headless.metadata.0.name
    template {
      metadata {
        labels = {
          app  = "postgresql"
          role = "master"
        }
        name = "postgresql"
      }
      spec {
        node_selector                   = var.master_node_selector
        service_account_name            = kubernetes_service_account.postgres.metadata.0.name
        automount_service_account_token = true
        security_context {
          # https://github.com/docker-library/postgres/blob/ff832cbf1e9ffe150f66f00a0837d5b59083fec9/10/Dockerfile#L16
          run_as_user = 999
          fs_group    = 999
        }
        container {
          env {
            name  = "PGDATA"
            value = "/var/lib/postgresql/data/11"
          }
          env {
            name  = "POSTGRES_USER"
            value = "postgres"
          }
          env {
            name = "POSTGRES_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.postgres.metadata.0.name
                key  = "POSTGRES_PASSWORD"
              }
            }
          }
          env {
            name  = "REPLICA_USER"
            value = "replica"
          }
          env {
            name = "REPLICA_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.postgres.metadata.0.name
                key  = "REPLICA_PASSWORD"
              }
            }
          }
          image = var.image
          args  = ["postgres", "-c", "config_file=/etc/postgresql/postgresql.conf"]
          security_context {
            allow_privilege_escalation = false
          }
          liveness_probe {
            initial_delay_seconds = 30
            timeout_seconds       = 5
            period_seconds        = 10
            failure_threshold     = 6
            success_threshold     = 1
            exec {
              command = ["sh", "-c", "exec", "pg_isready"]
            }
          }
          readiness_probe {
            initial_delay_seconds = 5
            timeout_seconds       = 5
            period_seconds        = 10
            failure_threshold     = 6
            success_threshold     = 1
            exec {
              command = ["sh", "-c", "exec", "pg_isready"]
            }
          }
          name = "postgresql"
          port {
            container_port = 5432
            name           = "postgresql"
            protocol       = "TCP"
          }
          volume_mount {
            mount_path = "/var/lib/postgresql/data"
            name       = "pg-data"
          }
          volume_mount {
            mount_path = "/etc/postgresql/postgresql.conf"
            name       = "postgres-config"
            sub_path   = "postgresql.conf"
          }
          volume_mount {
            mount_path = "/docker-entrypoint-initdb.d/"
            name       = "postgres-bootstrap"
          }
        }
        init_container {
          name    = "init-chmod-data"
          command = ["sh", "-c", "chown -R 999:999 /var/lib/postgresql/data;"]
          image   = "busybox"
          security_context {
            run_as_user = 0
          }
          volume_mount {
            mount_path = "/var/lib/postgresql/data"
            name       = "pg-data"
          }
        }
        volume {
          name = "postgres-config"
          config_map {
            name = kubernetes_config_map.postgres_conf.metadata.0.name
            items {
              key  = "postgresql.conf"
              path = "postgresql.conf"
            }
          }
        }
        volume {
          name = "postgres-bootstrap"
          config_map {
            name         = kubernetes_config_map.postgres_conf.metadata.0.name
            default_mode = "0750"
            items {
              key  = "00configure.sh"
              path = "00configure.sh"
            }
          }
        }

        termination_grace_period_seconds = 30
      }
    }
    volume_claim_template {
      metadata {
        name = "pg-data"
      }
      spec {
        storage_class_name = var.disk_type
        access_modes       = ["ReadWriteOnce"]
        resources {
          requests = {
            storage = "${var.disk_size}Gi"
          }
        }
      }
    }
    update_strategy {
      type = "RollingUpdate"
    }
  }
}