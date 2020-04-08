locals {
  domains = {
    monitoring = module.google_cloud_jordan.ingress_static_ipv4
    gitlab     = google_compute_forwarding_rule.gitlab.ip_address
    registry   = google_compute_forwarding_rule.gitlab.ip_address
    minio      = google_compute_forwarding_rule.gitlab.ip_address
  }
}

resource "google_dns_record_set" "apps" {
  for_each = local.domains

  managed_zone = local.dns_zone_name
  name         = "${each.key}.${local.dns_zone}."
  type         = "A"
  ttl          = 300

  rrdatas = [each.value]
}

