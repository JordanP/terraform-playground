resource "random_id" "postgres_conf" {
  byte_length = 8
  keepers = {
    "postgresql.conf" = var.postgresql_conf
  }
}

resource "kubernetes_config_map" "postgres_conf" {
  metadata {
    name      = "postgresql-config-${random_id.postgres_conf.hex}"
    namespace = (var.namespace != "default" ? kubernetes_namespace.postgresql[0].metadata.0.name : "default")
  }
  data = {
    "postgresql.conf" = var.postgresql_conf
  }
}

resource "kubernetes_config_map" "postgres_initd_script" {
  metadata {
    name      = "postgres-initd-script"
    namespace = (var.namespace != "default" ? kubernetes_namespace.postgresql[0].metadata.0.name : "default")
  }
  data = {
    "00configure.sh" = file("${path.module}/files/00configure.sh")
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