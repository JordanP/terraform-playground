resource "kubernetes_stateful_set" "rabbitmq" {
  metadata {
    name      = "rabbitmq"
    namespace = (var.namespace != "default" ? kubernetes_namespace.rabbitmq[0].metadata.0.name : "default")
    labels = {
      app = "rabbitmq"
    }
  }
  spec {
    service_name = "rabbitmq"
    replicas     = var.replica_count
    volume_claim_template {
      metadata {
        name = "rabbitmq-data"
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
    template {
      metadata {
        labels = {
          app = "rabbitmq"
        }
      }
      spec {
        node_selector                   = var.node_selector
        service_account_name            = kubernetes_service_account.rabbitmq.metadata.0.name
        automount_service_account_token = true
        security_context {
          run_as_user = 999
          fs_group    = 999
        }
        init_container {
          name  = "volume-permissions"
          image = "busybox:latest"
          # Delete the cached Erlang cookie: as we are always providing it, we are authoritative. This is consistent
          # with what both stable Helm charts (rabbitmq and rabbitmq-ha) do.
          command = ["sh", "-c", "cp /configmap/* /etc/rabbitmq; rm -f /var/lib/rabbitmq/.erlang.cookie"]
          volume_mount {
            mount_path = "/var/lib/rabbitmq"
            name       = "rabbitmq-data"
          }
          volume_mount {
            mount_path = "/configmap"
            name       = "configmap"
          }
          volume_mount {
            mount_path = "/etc/rabbitmq"
            name       = "rabbitmq-config"
          }
        }
        container {
          name  = "rabbitmq"
          image = var.image
          security_context {
            allow_privilege_escalation = false
          }
          lifecycle {
            pre_stop {
              exec {
                command = ["rabbitmqctl", "shutdown"]
              }
            }
          }
          # Liveness/readiness timing from https://github.com/helm/charts/tree/master/stable/rabbitmq
          liveness_probe {
            initial_delay_seconds = 120
            timeout_seconds       = 20
            period_seconds        = 30
            failure_threshold     = 6
            success_threshold     = 1
            exec {
              command = ["rabbitmqctl", "node_health_check"]
            }
          }
          readiness_probe {
            initial_delay_seconds = 10
            timeout_seconds       = 20
            period_seconds        = 30
            failure_threshold     = 3
            success_threshold     = 1
            exec {
              command = ["rabbitmqctl", "node_health_check"]
            }
          }
          port {
            container_port = 4369
            name           = "epmd"
          }
          port {
            container_port = 5672
            name           = "amqp"
          }
          port {
            container_port = 15672
            name           = "manager"
          }
          port {
            container_port = 25672
            name           = "dist"
          }
          volume_mount {
            mount_path = "/var/lib/rabbitmq"
            name       = "rabbitmq-data"
          }
          volume_mount {
            mount_path = "/etc/rabbitmq"
            name       = "rabbitmq-config"
          }
          env {
            name = "MY_POD_NAME"
            value_from {
              field_ref {
                field_path = "metadata.name"
              }
            }
          }
          env {
            name  = "RABBITMQ_USE_LONGNAME"
            value = "true"
          }
          env {
            name = "RABBITMQ_NODENAME"
            # We can't take the usual kubernetes_namespace.rabbitmq[0].metadata.0.name here because if
            # namespace == default the whole value evaluates to ""... Might be a TF quirck
            value = "rabbit@$(MY_POD_NAME).${kubernetes_service.rabbitmq.metadata.0.name}.${kubernetes_service.rabbitmq.metadata.0.namespace}.svc.cluster.local"
          }
          env {
            name  = "K8S_HOSTNAME_SUFFIX"
            value = ".${kubernetes_service.rabbitmq.metadata.0.name}.${kubernetes_service.rabbitmq.metadata.0.namespace}.svc.cluster.local"
          }
          env {
            name  = "K8S_SERVICE_NAME"
            value = kubernetes_service.rabbitmq.metadata.0.name
          }
          env {
            name = "RABBITMQ_ERLANG_COOKIE"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.rabbitmq.metadata.0.name
                key  = "erlang-cookie"
              }
            }
          }
        }
        affinity {
          pod_anti_affinity {
            required_during_scheduling_ignored_during_execution {
              topology_key = "kubernetes.io/hostname"
              label_selector {
                match_labels = {
                  app = "rabbitmq"
                }
              }
            }
          }
        }
        volume {
          name = "configmap"
          config_map {
            name = kubernetes_config_map.rabbitmq.metadata.0.name
          }
        }
        volume {
          name = "rabbitmq-config"
          empty_dir {
            medium = "Memory"
          }
        }
      }
    }
    selector {
      match_labels = {
        app = "rabbitmq"
      }
    }
    update_strategy {
      type = "RollingUpdate"
    }
  }
}