resource "kubernetes_cluster_role_binding" "kube_state_metrics" {
  metadata {
    name = "kube-state-metrics"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "kube-state-metrics"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "kube-state-metrics"
    namespace = var.namespace
  }
}
