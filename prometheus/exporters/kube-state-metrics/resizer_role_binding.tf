resource "kubernetes_role_binding" "kube-state-metrics" {
  metadata {
    name      = "kube-state-metrics"
    namespace = "${var.namespace}"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "kube-state-metrics-resizer"
  }

  subject {
    kind      = "ServiceAccount"
    namespace = "${var.namespace}"
    name      = "${kubernetes_service_account.kube_state_metrics.metadata.0.name}"
  }
}
