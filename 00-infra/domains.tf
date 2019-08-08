locals {
  app-domains = [
    "monitoring",
  ]

  gitlab-domains = [
    "gitlab",
    "registry",
    "minio",
  ]
}

resource "google_dns_record_set" "apps" {
  count = length(local.app-domains)

  managed_zone = local.dns_zone_name
  name         = "${element(local.app-domains, count.index)}.${local.dns_zone}."
  type         = "A"
  ttl          = 300

  rrdatas = [
    module.google-cloud-jordan.ingress_static_ipv4,
  ]
}

resource "google_dns_record_set" "gitlab" {
  count = length(local.gitlab-domains)

  managed_zone = local.dns_zone_name
  name         = "${element(local.gitlab-domains, count.index)}.${local.dns_zone}."
  type         = "A"
  ttl          = 300

  rrdatas = [
    google_compute_forwarding_rule.gitlab.ip_address,
  ]
}

