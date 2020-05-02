resource "kubernetes_stateful_set" "postgresql_replica" {
  metadata {
    labels = {
      app = "postgresql"
    }
    name      = "pg-replica"
    namespace = (var.namespace != "default" ? kubernetes_namespace.postgresql[0].metadata.0.name : "default")
  }
  spec {
    service_name = kubernetes_service.postgres_headless.metadata.0.name
    replicas     = var.replica_count
    selector {
      match_labels = {
        app  = "postgresql"
        role = "replica"
      }
    }
    template {
      metadata {
        labels = {
          app  = "postgresql"
          role = "replica"
        }
        name = "postgresql"
      }
      spec {
        node_selector                   = var.replica_node_selector
        service_account_name            = kubernetes_service_account.postgres.metadata.0.name
        automount_service_account_token = true
        security_context {
          # https://github.com/docker-library/postgres/blob/ff832cbf1e9ffe150f66f00a0837d5b59083fec9/10/Dockerfile#L16
          run_as_user = 999
          fs_group    = 999
        }
        container {
          name = "postgres"
          port {
            container_port = 5432
            name           = "postgresql"
            protocol       = "TCP"
          }
          env {
            name  = "PGDATA"
            value = "/var/lib/postgresql/data/11"
          }
          env {
            name  = "MAIN_HOSTNAME"
            value = kubernetes_service.postgres_rw.metadata.0.name
          }
          env {
            name  = "POSTGRES_PASSWORD"
            value = "doesntmatter"
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
          args  = ["postgres", "-c", "config_file=/etc/postgresql/postgresql.conf", "-c", "hot_standby_feedback=on"]
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
          volume_mount {
            mount_path = "/var/lib/postgresql/data/"
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
            name = kubernetes_config_map.postgres_conf_replica.metadata.0.name
          }
        }
        volume {
          name = "postgres-bootstrap"
          config_map {
            name         = kubernetes_config_map.postgres_initd_script.metadata.0.name
            default_mode = "0750"
          }
        }
        # It is recommended that in a Kubernetes environment you set the terminationGracePeriodSeconds parameter
        # to be two (2) seconds higher than the PGCTLTIMEOUT value that defaults to 60.
        termination_grace_period_seconds = 62
        affinity {
          pod_anti_affinity {
            required_during_scheduling_ignored_during_execution {
              topology_key = "kubernetes.io/hostname"
              label_selector {
                match_labels = {
                  app  = "postgresql"
                  role = "replica"
                }
              }
            }
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
