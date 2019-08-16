resource "kubernetes_service_account" "rabbitmq" {
  metadata {
    name      = "rabbitmq"
    namespace = kubernetes_namespace.rabbitmq[0].metadata.0.name

  }
  automount_service_account_token = true
}

resource "kubernetes_role" "endpoint_reader" {
  metadata {
    name      = "endpoint-reader"
    namespace = kubernetes_namespace.rabbitmq[0].metadata.0.name

  }
  rule {
    api_groups = [""]
    verbs      = ["get"]
    resources  = ["endpoints"]
  }
}

resource "kubernetes_role_binding" "rabbitmq_endpoint_reader" {
  metadata {
    name      = "rabbitmq-endpoint-reader"
    namespace = kubernetes_namespace.rabbitmq[0].metadata.0.name

  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.endpoint_reader.metadata.0.name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.rabbitmq.metadata.0.name
    namespace = kubernetes_namespace.rabbitmq[0].metadata.0.name
  }
}
