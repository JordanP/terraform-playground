resource "kubernetes_service_account" "kube_state_metrics" {
  automount_service_account_token = true
  metadata {
    name      = "kube-state-metrics"
    namespace = var.namespace
  }
}
