resource "kubernetes_stateful_set" "postgresql-slave" {
  metadata {
    labels = {
      app = "postgresql"
    }
    name      = "pg-replica"
    namespace = (var.namespace != "default" ? kubernetes_namespace.postgresql[0].metadata.0.name : "default")
  }
  spec {
    service_name = kubernetes_service.postgres_headless.metadata.0.name
    replicas     = var.slave_count
    selector {
      match_labels = {
        app  = "postgresql"
        role = "slave"
      }
    }
    template {
      metadata {
        labels = {
          app  = "postgresql"
          role = "slave"
        }
        name = "postgresql"
      }
      spec {
        node_selector = var.slave_node_selector
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
          env {
            name  = "TRIGGER_FILE"
            value = "/tmp/postgresql.trigger.5432"
          }
          image = var.image
          args  = ["postgres", "-c", "config_file=/etc/postgresql/postgresql.conf", "-c", "hot_standby_feedback=on"]

          image_pull_policy = "Always"
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
        affinity {
          pod_anti_affinity {
            preferred_during_scheduling_ignored_during_execution {
              weight = 1
              pod_affinity_term {
                topology_key = "kubernetes.io/hostname"
                label_selector {
                  match_expressions {
                    key      = "app"
                    operator = "In"
                    values   = ["postgresql"]
                  }
                }
              }
            }
          }
        }
      }
    }

    volume_claim_template {
      metadata {
        name      = "pg-data"
        namespace = (var.namespace != "default" ? kubernetes_namespace.postgresql[0].metadata.0.name : "default")
      }
      spec {
        storage_class_name = var.slave_disk_type
        access_modes       = ["ReadWriteOnce"]
        resources {
          requests = {
            storage = "${var.slave_disk_size}Gi"
          }
        }
      }
    }
    update_strategy {
      type = "RollingUpdate"
    }
  }
}
