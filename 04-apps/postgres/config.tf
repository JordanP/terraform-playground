resource "kubernetes_config_map" "postgres_conf_primary" {
  metadata {
    name      = "postgresql-config-primary"
    namespace = (var.namespace != "default" ? kubernetes_namespace.postgresql[0].metadata.0.name : "default")
  }
  data = {
    "postgresql.conf" = templatefile(var.postgresql_conf_template, {
      "max_connections" : var.postgresql_primary_max_connections
      "work_mem" : var.postgresql_primary_work_mem
      "effective_cache_size" : var.postgresql_primary_effective_cache_size
      "shared_buffers" : var.postgresql_primary_shared_buffers
      "maintenance_work_mem": var.postgresql_primary_maintenance_work_mem
    })
  }
}

resource "kubernetes_config_map" "postgres_conf_replica" {
  metadata {
    name      = "postgresql-config-replica"
    namespace = (var.namespace != "default" ? kubernetes_namespace.postgresql[0].metadata.0.name : "default")
  }
  data = {
    "postgresql.conf" = templatefile(var.postgresql_conf_template, {
      # Needs to be higher than on primary otherwise replica won't start.
      "max_connections" : max(var.postgresql_replica_max_connections, var.postgresql_primary_max_connections)
      "work_mem" : var.postgresql_replica_work_mem
      "effective_cache_size" : var.postgresql_replica_effective_cache_size
      "shared_buffers" : var.postgresql_replica_shared_buffers
      "maintenance_work_mem": var.postgresql_replica_maintenance_work_mem
    })
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
    name      = "postgres"
    namespace = (var.namespace != "default" ? kubernetes_namespace.postgresql[0].metadata.0.name : "default")
  }
  data = {
    POSTGRES_PASSWORD = random_id.postgres_password.hex
    REPLICA_PASSWORD  = random_id.replica_password.hex
  }
}