locals {
  pgbouncer_service_hostname = "${kubernetes_service.pgbouncer.metadata.0.name}.${kubernetes_service.pgbouncer.metadata.0.namespace}"
}

output "pgbouncer_service_hostname" {
  value = local.pgbouncer_service_hostname
}
