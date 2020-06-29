locals {
  termination_grace_period_seconds = 60
}

resource "kubernetes_deployment" "pg_bouncer" {
  metadata {
    name      = "pg-bouncer"
    namespace = var.namespace
    labels = {
      app = "pg-bouncer"
    }
  }
  spec {
    replicas = var.replicas
    selector {
      match_labels = {
        app = "pg-bouncer"
      }
    }
    template {
      metadata {
        labels = {
          app = "pg-bouncer"
        }
      }
      spec {
        node_selector = var.node_selector
        container {
          name  = "pgbouncer"
          image = "tophfr/pgbouncer:1.12.0@sha256:9ba3b0e56bb37b91de6674327e96fc4d5822ecbf7f7f17fa3d9856e5ab2cc868"
          port {
            container_port = 5432
            name           = "pg-bouncer"
          }
          volume_mount {
            mount_path = "/etc/pgbouncer"
            name       = "pgbouncer-config"
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
                # Safe shutdown. Same as issuing PAUSE and SHUTDOWN on the console.
                # What we don't want to see in PGBouncer logs is "got SIGTERM, fast exit", instead we want
                # "got SIGINT, shutting down" and eventually "server connections dropped, exiting"
                # PGBouncer entrypoint uses "exec pgbouncer" so pgbouncer has PID 1
                # For some reason, we have to spawn a shell here command = ["kill", "-s", "INT", "1"] doesn't work
                # Also, if after some time all the connections have not been closed, then the preStop hook will return
                # and the regular SIGTERM (fast exit) will proceed
                command = ["sh", "-c", "kill -s INT 1 && sleep $((${local.termination_grace_period_seconds} - 2))"]
              }
            }
          }
          liveness_probe {
            tcp_socket {
              port = "5432"
            }
            initial_delay_seconds = 60
            period_seconds        = 10
          }
          readiness_probe {
            tcp_socket {
              port = "5432"
            }
            initial_delay_seconds = 20
            failure_threshold     = 6
            period_seconds        = 10
          }
        }
        volume {
          name = "pgbouncer-config"
          config_map {
            name = kubernetes_config_map.pgbouncer_config.metadata.0.name
          }
        }
        # Extend the grace period to let the long running queries terminate
        termination_grace_period_seconds = local.termination_grace_period_seconds
      }
    }
  }
}
