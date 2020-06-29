resource "kubernetes_stateful_set" "postgres_primary" {
  metadata {
    labels = {
      app = "postgresql"
    }
    name      = "pg-primary"
    namespace = (var.namespace != "default" ? kubernetes_namespace.postgresql[0].metadata.0.name : "default")
  }
  spec {
    replicas = "1"
    selector {
      match_labels = {
        app  = "postgresql"
        role = "primary"
      }
    }
    service_name = kubernetes_service.postgres_headless.metadata.0.name
    template {
      metadata {
        labels = {
          app  = "postgresql"
          role = "primary"
        }
        name = "postgresql"
      }
      spec {
        node_selector                   = var.primary_node_selector
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
            value = "${local.pgdata}/${local.pgmajor}"
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
            mount_path = local.pgdata
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
          resources {
            requests {
              cpu    = var.resources.cpu
              memory = var.resources.memory
            }
            limits {
              cpu    = var.resources.cpu
              memory = var.resources.memory
            }
          }
          lifecycle {
            pre_stop {
              exec {
                # This is the Fast Shutdown mode. The server disallows new connections and sends all existing server
                # processes SIGTERM, which will cause them to abort their current transactions and exit promptly. It
                # then waits for all server processes to exit and finally shuts down.
                # Postgres entrypoint uses "exec postgres" so postgres has PID 1
                # For some reason, we have to spawn a shell here command = ["kill", "-s", "INT", "1"] doesn't work
                # Also, for some reason, using pg_ctl -D ... -m fast didn't work either
                command = ["sh", "-c", "kill -s INT 1 && sleep $((${local.termination_grace_period_seconds} - 3))"]
              }
            }
          }
        }
        # Note(JordanP): As this is the master, we are not that interested in graceful
        # shutdown. We want this to restart ASAP to limit downtime.
        # When a pod is deleted, it is sent a SIGTERM which PG interprets as "Smart Shutdown mode", which "lets existing
        # sessions end their work normally". But this may take a long time so we have a preStop hook to do a fast
        # shutdown instead.
        termination_grace_period_seconds = local.termination_grace_period_seconds
        init_container {
          name    = "init-chmod-data"
          command = ["sh", "-c", "chown -R 999:999 ${local.pgdata};"]
          image   = "busybox"
          security_context {
            run_as_user = 0
          }
          volume_mount {
            mount_path = local.pgdata
            name       = "pg-data"
          }
        }
        volume {
          name = "postgres-config"
          config_map {
            name = kubernetes_config_map.postgres_conf_primary.metadata.0.name
          }
        }
        volume {
          name = "postgres-bootstrap"
          config_map {
            name         = kubernetes_config_map.postgres_initd_script.metadata.0.name
            default_mode = "0750"
          }
        }
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