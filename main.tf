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

  /*providers = {
    kubernetes = "kubernetes"
  }*/
}

module "grafana" {
  source = "./grafana"

  /*providers = {
    kubernetes = "kubernetes"
  }*/
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
  worker_count    = 2
  controller_type = "g1-small"
  worker_type     = "g1-small"
}
