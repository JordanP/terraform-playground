resource "kubernetes_daemonset" "node" {
  metadata {
    name      = "csi-gce-pd-node"
    namespace = kubernetes_namespace.gce_pd_csi.metadata.0.name
  }
  spec {
    selector {
      match_labels = {
        app = "gcp-compute-persistent-disk-csi-driver"
      }
    }
    template {
      metadata {
        labels = {
          app = "gcp-compute-persistent-disk-csi-driver"
        }
      }
      spec {
        service_account_name            = kubernetes_service_account.csi_gce_pd_node_sa.metadata.0.name
        automount_service_account_token = true
        container {
          name  = "csi-driver-registrar"
          image = "gke.gcr.io/csi-node-driver-registrar:v1.2.0-gke.0"
          args  = ["--v=5", "--csi-address=/csi/csi.sock", "--kubelet-registration-path=/var/lib/kubelet/plugins/pd.csi.storage.gke.io/csi.sock"]
          lifecycle {
            pre_stop {
              exec {
                command = [
                  "/bin/sh", "-c", "rm -rf /registration/pd.csi.storage.gke.io /registration/pd.csi.storage.gke.io-reg.sock"
                ]
              }
            }
          }
          env {
            name = "KUBE_NODE_NAME"
            value_from {
              field_ref {
                field_path = "spec.nodeName"
              }
            }
          }
          volume_mount {
            mount_path = "/csi"
            name       = "plugin-dir"
          }
          volume_mount {
            mount_path = "/registration"
            name       = "registration-dir"
          }

        }
        container {
          name = "gce-pd-driver"
          security_context {
            privileged = true
          }
          image = "gke.gcr.io/gcp-compute-persistent-disk-csi-driver:v0.7.0-gke.0"
          args  = ["--v=5", "--endpoint=unix:/csi/csi.sock"]
          env {
            name  = "GOOGLE_APPLICATION_CREDENTIALS"
            value = "/etc/cloud-sa/cloud-sa.json"
          }
          volume_mount {
            mount_path = "/etc/cloud-sa"
            name       = "cloud-sa-volume"
            read_only  = true
          }
          volume_mount {
            mount_path        = "/var/lib/kubelet"
            name              = "kubelet-dir"
            mount_propagation = "Bidirectional"
          }
          volume_mount {
            mount_path = "/csi"
            name       = "plugin-dir"
          }
          volume_mount {
            mount_path = "/dev"
            name       = "device-dir"
          }
          volume_mount {
            mount_path = "/etc/udev"
            name       = "udev-rules-etc"
          }
          volume_mount {
            mount_path = "/lib/udev"
            name       = "udev-rules-lib"
          }
          volume_mount {
            mount_path = "/run/udev"
            name       = "udev-socket"
          }
          volume_mount {
            mount_path = "/sys"
            name       = "sys"
          }

        }
        volume {
          name = "registration-dir"
          host_path {
            path = "/var/lib/kubelet/plugins_registry/"
            type = "Directory"
          }
        }
        volume {
          name = "kubelet-dir"
          host_path {
            path = "/var/lib/kubelet"
            type = "Directory"
          }
        }
        volume {
          name = "plugin-dir"
          host_path {
            path = "/var/lib/kubelet/plugins/pd.csi.storage.gke.io/"
            type = "DirectoryOrCreate"
          }
        }
        volume {
          name = "device-dir"
          host_path {
            path = "/dev"
            type = "Directory"
          }
        }
        volume {
          name = "udev-rules-etc"
          host_path {
            path = "/etc/udev"
            type = "Directory"
          }
        }
        volume {
          name = "udev-rules-lib"
          host_path {
            path = "/lib/udev"
            type = "Directory"
          }
        }
        volume {
          name = "udev-socket"
          host_path {
            path = "/run/udev"
            type = "Directory"
          }
        }
        volume {
          name = "sys"
          host_path {
            path = "/sys"
            type = "Directory"
          }
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
