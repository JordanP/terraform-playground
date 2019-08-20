resource "kubernetes_namespace" "rabbitmq" {
  count = (var.namespace != "default" ? 1 : 0)
  metadata {
    name = var.namespace
  }
}

resource "random_string" "erlang_cookie" {
  length  = 48
  special = false
}

resource "kubernetes_secret" "rabbitmq_config" {
  metadata {
    name      = "rabbitmq-config"
    namespace = (var.namespace != "default" ? kubernetes_namespace.rabbitmq[0].metadata.0.name : "default")
  }

  data = {
    erlang-cookie = random_string.erlang_cookie.result
  }
}