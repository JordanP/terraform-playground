output "monitoring_hostname" {
  value = "monitoring.${local.dns_zone}"
}

output "certificate" {
  value = "${acme_certificate.default.certificate_pem}${acme_certificate.default.issuer_pem}"
}

output "private_key" {
  value     = acme_certificate.default.private_key_pem
  sensitive = true
}