resource "kubernetes_role" "kube_state_metrics_resizer" {
  metadata {
    name      = "kube-state-metrics-resizer"
    namespace = var.namespace
  }

  rule {
    api_groups = [
      "",
    ]

    resources = [
      "pods",
    ]

    verbs = [
      "get",
    ]
  }

  rule {
    api_groups = [
      "apps",
    ]

    resources = [
      "pods",
    ]

    resource_names = [
    "kube-state-metrics"]

    verbs = [
      "get",
      "update",
    ]
  }

  rule {
    api_groups = [
      "extensions",
    ]

    resources = [
      "deployments",
    ]

    resource_names = [
    "kube-state-metrics"]

    verbs = [
      "get",
      "update",
    ]
  }
}
