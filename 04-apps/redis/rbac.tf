resource "kubernetes_service_account" "redis" {
  metadata {
    name = "redis"
    labels = {
      app = "redis"
    }
  }
}
/*
resource "kubernetes_role" "redis" {
  metadata {
    name = "redis"
    labels = {
      app = "redis"
    }
  }
  rule {
    api_groups = []
    resources  = []
    verbs      = []
  }
}

resource "kubernetes_role_binding" "redis" {
  metadata {
    name = "redis"
    labels = {
      app = "redis"
    }
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.redis.metadata.0.name
  }
  subject {
    kind = "ServiceAccount"
    name = kubernetes_service_account.redis.metadata.0.name
  }
}*/