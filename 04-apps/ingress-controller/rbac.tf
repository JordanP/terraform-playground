resource "kubernetes_service_account" "ingress" {
  automount_service_account_token = true
  metadata {
    name      = "nginx-ingress-serviceaccount"
    namespace = kubernetes_namespace.ingress.metadata[0].name
  }
}

resource "kubernetes_cluster_role_binding" "ingress" {
  metadata {
    name = "ingress"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "ingress"
  }

  subject {
    kind      = "ServiceAccount"
    namespace = kubernetes_namespace.ingress.metadata[0].name
    name      = kubernetes_service_account.ingress.metadata[0].name
  }
}

resource "kubernetes_cluster_role" "ingress" {
  metadata {
    name = "ingress"
  }

  rule {
    api_groups = [
      "",
    ]

    resources = [
      "configmaps",
      "endpoints",
      "nodes",
      "pods",
      "secrets",
    ]

    verbs = [
      "list",
      "watch",
    ]
  }

  rule {
    api_groups = [
      "",
    ]
    resources = [
    "events", ]
    verbs = ["create", "patch"]
  }

  rule {
    api_groups = [
      "",
    ]

    resources = [
      "nodes",
    ]

    verbs = [
      "get",
    ]
  }

  rule {
    api_groups = [
      "",
    ]

    resources = [
      "services",
    ]

    verbs = [
      "get",
      "list",
      "watch",
    ]
  }

  rule {
    api_groups = [
      "networking.k8s.io",
      "extensions",
    ]

    resources = [
      "ingresses",
    ]

    verbs = [
      "get",
      "list",
      "watch",
    ]
  }

  rule {
    api_groups = [
      "",
    ]

    resources = [
      "events",
    ]

    verbs = [
      "create",
      "patch",
    ]
  }


  rule {
    api_groups = [
      "networking.k8s.io",
      "extensions",

    ]

    resources = [
      "ingresses/status",
    ]

    verbs = [
      "update",
    ]
  }
}

resource "kubernetes_role_binding" "ingress" {
  metadata {
    name      = "ingress"
    namespace = kubernetes_namespace.ingress.metadata[0].name
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "ingress"
  }

  subject {
    kind      = "ServiceAccount"
    namespace = kubernetes_namespace.ingress.metadata[0].name
    name      = kubernetes_service_account.ingress.metadata[0].name
  }
}

resource "kubernetes_role" "ingress" {
  metadata {
    name      = "ingress"
    namespace = kubernetes_namespace.ingress.metadata[0].name
  }

  rule {
    api_groups = [
      "",
    ]

    resources = [
      "configmaps",
      "pods",
      "secrets",
      "namespaces",
    ]

    verbs = [
      "get",
    ]
  }

  rule {
    api_groups = [
      "",
    ]

    resources = [
      "configmaps",
    ]

    resource_names = [
      "ingress-controller-leader-public",
    ]

    verbs = [
      "get",
      "update",
    ]
  }

  rule {
    api_groups = [
      "",
    ]

    resources = [
      "configmaps",
    ]

    verbs = [
      "create",
    ]
  }

  rule {
    api_groups = [
      "",
    ]

    resources = [
      "endpoints",
    ]

    verbs = [
      "get",
    ]
  }
}
