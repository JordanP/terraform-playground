locals {
  app-domains = [
    "monitoring",
    "gitlab",
    "registry",
    "minio",
  ]
}

resource "google_dns_record_set" "apps" {
  provider = "google.default"
  count    = "${length(local.app-domains)}"

  managed_zone = "${local.dns_zone_name}"
  name         = "${element(local.app-domains, count.index)}.${local.dns_zone}."
  type         = "A"
  ttl          = 300

  rrdatas = [
    "${module.google-cloud-jordan.ingress_static_ipv4}",
  ]
}
