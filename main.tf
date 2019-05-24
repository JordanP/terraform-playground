terraform {
  backend "gcs" {
    credentials = "account.json"
    bucket      = "tf-playground-tf-state"
  }
}

locals {
  project_id          = "terraform-playground-237915"
  cluster_name        = "jordan"
  dns_zone            = "jordanpittier.net"
  dns_zone_name       = "jordanpittier-net"
  asset_dir           = "/home/jordan/.secrets/clusters/tf-playground"
  gitlab_release_name = "my-gitlab"
}

module "nginx" {
  source              = "./ingress-controller"
  gitlab_release_name = "${local.gitlab_release_name}"
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

module "prometheus" {
  source    = "./prometheus"
  namespace = "${kubernetes_namespace.monitoring.metadata.0.name}"
}

module "google-cloud-jordan" {
  source = "git::https://github.com/poseidon/typhoon//google-cloud/container-linux/kubernetes?ref=93f7a3508a70d18841418a1a2183f9e815719383"

  # Google Cloud
  cluster_name  = "${local.cluster_name}"
  region        = "europe-west4"
  dns_zone      = "${local.dns_zone}"
  dns_zone_name = "${local.dns_zone_name}"

  # configuration
  ssh_authorized_key = "${file(pathexpand("~/.ssh/id_rsa.pub"))}"
  asset_dir          = "${local.asset_dir}"

  # optional
  worker_count       = 3
  controller_type    = "g1-small"
  worker_type        = "n1-standard-1"
  worker_preemptible = "true"

  providers = {
    google   = "google.default"
    local    = "local.default"
    null     = "null.default"
    template = "template.default"
    tls      = "tls.default"
  }
}
