output "postgres_rw_service" {
  value = "${kubernetes_service.postgres_rw.metadata.0.name}.${kubernetes_service.postgres_rw.metadata.0.namespace}"
}

output "postgres_password" {
  value     = random_id.postgres_password.hex
  sensitive = true
}