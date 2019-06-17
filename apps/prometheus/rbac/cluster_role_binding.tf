resource "kubernetes_cluster_role_binding" "prometheus" {
  metadata {
    name = "prometheus"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "prometheus"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "prometheus"
    namespace = var.namespace
  }
}
