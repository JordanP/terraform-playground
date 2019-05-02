terraform {
  backend "gcs" {
    credentials = "account.json"
    bucket      = "tf-playground-tf-state"
  }
}

locals {
  cluster_name  = "jordan"
  dns_zone      = "jordanpittier.net"
  dns_zone_name = "jordanpittier-net"
  asset_dir     = "/home/jordan/.secrets/clusters/tf-playground"
}

module "nginx" {
  source = "./ingress-controller"
}

resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"

    labels {
      name = "monitoring"
    }
  }
}

module "grafana" {
  source    = "./grafana"
  namespace = "${kubernetes_namespace.monitoring.metadata.0.name}"
}

resource "google_dns_record_set" "monitoring" {
  provider = "google.default"

  # DNS zone name
  managed_zone = "${local.dns_zone_name}"

  # DNS record
  name = "monitoring.${local.dns_zone}."
  type = "A"
  ttl  = 300

  rrdatas = [
    "${module.google-cloud-jordan.ingress_static_ipv4}",
  ]
}

module "prometheus" {
  source    = "./prometheus"
  namespace = "${kubernetes_namespace.monitoring.metadata.0.name}"
}

module "google-cloud-jordan" {
  source = "git::https://github.com/poseidon/typhoon//google-cloud/container-linux/kubernetes?ref=e73cccd7ebc669bc5de4af026a750786126095dd"

  providers = {
    google   = "google.default"
    local    = "local.default"
    null     = "null.default"
    template = "template.default"
    tls      = "tls.default"
  }

  # Google Cloud
  cluster_name  = "${local.cluster_name}"
  region        = "europe-west4"
  dns_zone      = "${local.dns_zone}"
  dns_zone_name = "${local.dns_zone_name}"

  # configuration
  ssh_authorized_key = "${file(pathexpand("~/.ssh/id_rsa.pub"))}"
  asset_dir          = "${local.asset_dir}"

  # optional
  worker_count       = 2
  controller_type    = "g1-small"
  worker_type        = "g1-small"
  worker_preemptible = "true"
}
