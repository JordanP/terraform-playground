resource "kubernetes_service_account" "tiller" {
  automount_service_account_token = true
  metadata {
    name      = "tiller"
    namespace = "kube-system"
  }
}

# terraform apply -auto-approve -target=kubernetes_cluster_role_binding.tiller
resource "kubernetes_cluster_role_binding" "tiller" {
  metadata {
    name = "tiller"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.tiller.metadata[0].name
    namespace = kubernetes_service_account.tiller.metadata[0].namespace
  }
}

resource "kubernetes_deployment" "tiller_with_rbac" {
  metadata {
    name      = "tiller-deploy"
    namespace = kubernetes_service_account.tiller.metadata[0].namespace

    labels = {
      app  = "helm"
      name = "tiller"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app  = "helm"
        name = "tiller"
      }
    }

    template {
      metadata {
        labels = {
          app  = "helm"
          name = "tiller"
        }
      }

      spec {
        service_account_name            = kubernetes_service_account.tiller.metadata[0].name
        automount_service_account_token = true
        container {
          name  = "tiller"
          image = "gcr.io/kubernetes-helm/tiller:v2.15.1"

          port {
            name           = "tiller"
            container_port = 44134
          }

          port {
            name           = "http"
            container_port = 44135
          }

          env {
            name  = "TILLER_NAMESPACE"
            value = kubernetes_service_account.tiller.metadata[0].namespace
          }

          env {
            name  = "TILLER_HISTORY_MAX"
            value = "0"
          }

          liveness_probe {
            http_get {
              path = "/liveness"
              port = 44135
            }

            initial_delay_seconds = 1
            timeout_seconds       = 2
          }

          readiness_probe {
            http_get {
              path = "/readiness"
              port = 44135
            }

            initial_delay_seconds = 1
            timeout_seconds       = 2
          }

        }
      }
    }
  }
  depends_on = [
    kubernetes_cluster_role_binding.tiller,
    kubernetes_service_account.tiller
  ]
}
