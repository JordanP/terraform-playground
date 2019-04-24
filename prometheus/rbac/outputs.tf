output "service_account_name" {
  value = "${kubernetes_service_account.prometheus.metadata.0.name}"
}

output "service_account_default_secret_name" {
  value = "${kubernetes_service_account.prometheus.default_secret_name}"
}
