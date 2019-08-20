resource "kubernetes_namespace" "postgresql" {
  count = (var.namespace != "default" ? 1 : 0)
  metadata {
    name = var.namespace
  }
}

resource "random_id" "postgres_password" {
  byte_length = 16
}

resource "random_id" "replica_password" {
  byte_length = 16
}

resource "kubernetes_secret" "postgres" {
  metadata {
    name      = "postgres-${random_id.postgres_password.hex}"
    namespace = (var.namespace != "default" ? kubernetes_namespace.postgresql[0].metadata.0.name : "default")
  }
  data = {
    POSTGRES_PASSWORD = random_id.postgres_password.hex
    REPLICA_PASSWORD  = random_id.replica_password.hex
  }
}
