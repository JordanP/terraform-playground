resource "kubernetes_stateful_set" "csi_gce_pd_controller" {
  metadata {
    name      = "csi-gce-pd-controller"
    namespace = kubernetes_namespace.gce_pd_csi.metadata.0.name
  }
  spec {
    service_name = "csi-gce-pd"
    replicas     = 1
    selector {
      match_labels = {
        app = "gcp-compute-persistent-disk-csi-driver"
      }
    }
    update_strategy {
      type = "RollingUpdate"
    }
    template {
      metadata {
        labels = {
          app = "gcp-compute-persistent-disk-csi-driver"
        }
      }
      spec {
        service_account_name            = kubernetes_service_account.csi_controller_sa.metadata.0.name
        automount_service_account_token = true
        container {
          name  = "csi-provisioner"
          image = "gke.gcr.io/csi-provisioner:v1.6.0-gke.0"
          args = [
            "--v=5",
            "--csi-address=/csi/csi.sock",
            "--feature-gates=Topology=true",
            "--metrics-address=:22011",
            "--enable-leader-election",
            "--leader-election-type=leases",
            "--leader-election-namespace=$(PDCSI_NAMESPACE)",
          ]
          env {
            name = "PDCSI_NAMESPACE"
            value_from {
              field_ref {
                field_path = "metadata.namespace"
              }
            }
          }
          volume_mount {
            mount_path = "/csi"
            name       = "socket-dir"
          }

        }
        container {
          name  = "csi-attacher"
          image = "gke.gcr.io/csi-attacher:v2.2.0-gke.0"
          args = [
            "--v=5",
            "--csi-address=/csi/csi.sock",
            "--metrics-address=:22012",
            "--leader-election",
            "--leader-election-namespace=$(PDCSI_NAMESPACE)",
          ]
          env {
            name = "PDCSI_NAMESPACE"
            value_from {
              field_ref {
                field_path = "metadata.namespace"
              }
            }
          }
          volume_mount {
            mount_path = "/csi"
            name       = "socket-dir"
          }
        }
        container {
          name  = "csi-resizer"
          image = "gke.gcr.io/csi-resizer:v0.5.0-gke.0"
          args = [
            "--v=5",
            "--csi-address=/csi/csi.sock",
            "--metrics-address=:22013",
            "--leader-election",
            "--leader-election-namespace=$(PDCSI_NAMESPACE)",
          ]
          env {
            name = "PDCSI_NAMESPACE"
            value_from {
              field_ref {
                field_path = "metadata.namespace"
              }
            }
          }
          volume_mount {
            mount_path = "/csi"
            name       = "socket-dir"
          }
        }
        container {
          name  = "csi-snapshotter"
          image = "gke.gcr.io/csi-snapshotter:v2.1.1-gke.0"
          args = [
            "--v=5",
            "--csi-address=/csi/csi.sock",
            "--metrics-address=:22014",
            "--leader-election",
            "--leader-election-namespace=$(PDCSI_NAMESPACE)",
          ]
          env {
            name = "PDCSI_NAMESPACE"
            value_from {
              field_ref {
                field_path = "metadata.namespace"
              }
            }
          }
        }
        container {
          name  = "gce-pd-driver"
          image = "gke.gcr.io/gcp-compute-persistent-disk-csi-driver:v0.7.0-gke.0"
          args  = ["--v=5", "--endpoint=unix:/csi/csi.sock"]
          env {
            name  = "GOOGLE_APPLICATION_CREDENTIALS"
            value = "/etc/cloud-sa/cloud-sa.json"
          }
          volume_mount {
            mount_path = "/csi"
            name       = "socket-dir"
          }
          volume_mount {
            mount_path = "/etc/cloud-sa"
            name       = "cloud-sa-volume"
            read_only  = true
          }
        }
        volume {
          name = "socket-dir"
          empty_dir {}
        }
        volume {
          name = "cloud-sa-volume"
          secret {
            secret_name = kubernetes_secret.cloud_sa.metadata.0.name
          }
        }
      }
    }
  }
}
