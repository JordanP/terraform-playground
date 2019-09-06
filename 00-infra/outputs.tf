output "monitoring_hostname" {
  value = "monitoring.${local.dns_zone}"
}

output "certificate" {
  value     = acme_certificate.certificate.certificate_pem
  sensitive = true
}

output "private_key" {
  value     = acme_certificate.certificate.private_key_pem
  sensitive = true
}