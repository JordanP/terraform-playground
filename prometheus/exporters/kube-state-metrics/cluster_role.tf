resource "kubernetes_cluster_role" "kube_state_metrics" {
  metadata {
    name = "kube-state-metrics"
  }

  rule {
    api_groups = [
      "",
    ]

    resources = [
      "configmaps",
      "secrets",
      "nodes",
      "pods",
      "services",
      "resourcequotas",
      "replicationcontrollers",
      "limitranges",
      "persistentvolumeclaims",
      "persistentvolumes",
      "namespaces",
      "endpoints",
    ]

    verbs = [
      "list",
      "watch",
    ]
  }

  rule {
    api_groups = [
      "extensions",
    ]

    resources = [
      "daemonsets",
      "deployments",
      "replicasets",
      "ingresses",
    ]

    verbs = [
      "list",
      "watch",
    ]
  }

  rule {
    api_groups = [
      "apps",
    ]

    resources = [
      "daemonsets",
      "deployments",
      "replicasets",
      "statefulsets",
    ]

    verbs = [
      "list",
      "watch",
    ]
  }

  rule {
    api_groups = [
      "batch",
    ]

    resources = [
      "cronjobs",
      "jobs",
    ]

    verbs = [
      "list",
      "watch",
    ]
  }

  rule {
    api_groups = [
      "autoscaling",
    ]

    resources = [
      "horizontalpodautoscalers",
    ]

    verbs = [
      "list",
      "watch",
    ]
  }

  rule {
    api_groups = [
      "certificates.k8s.io",
    ]

    resources = [
      "certificatesigningrequests",
    ]

    verbs = [
      "list",
      "watch",
    ]
  }

  rule {
    api_groups = [
      "policy",
    ]

    resources = [
      "poddisruptionbudgets",
    ]

    verbs = [
      "list",
      "watch",
    ]
  }
}