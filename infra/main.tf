terraform {
  backend "gcs" {
    credentials = "../account.json"
    bucket      = "tf-playground-tf-state"
    prefix      = "infra"
  }
}

locals {
  project_id    = "terraform-playground-237915"
  cluster_name  = "jordan"
  dns_zone      = "jordanpittier.net"
  dns_zone_name = "jordanpittier-net"
  asset_dir     = "/home/jordan/.secrets/clusters/tf-playground"
}

resource "google_compute_firewall" "git_clone_ssh" {
  name    = "git-clone-ssh"
  network = module.google-cloud-jordan.network_name

  allow {
    protocol = "TCP"

    ports = [
      8022,
    ]
  }

  target_tags = [
    "${local.cluster_name}-worker",
  ]
}

resource "google_compute_forwarding_rule" "gitlab" {
  name       = "gitlab"
  target     = module.google-cloud-jordan.worker_target_pool
  port_range = "1-65535"
}

module "google-cloud-jordan" {
  source = "git::https://github.com/poseidon/typhoon//google-cloud/container-linux/kubernetes?ref=ce7bff0066703aac70bccd85c73ca52b6e1b78d0"

  # Google Cloud
  cluster_name  = local.cluster_name
  region        = "europe-west4"
  dns_zone      = local.dns_zone
  dns_zone_name = local.dns_zone_name

  # configuration
  ssh_authorized_key = file(pathexpand("~/.ssh/id_rsa.pub"))
  asset_dir          = local.asset_dir

  # optional
  worker_count       = 3
  controller_type    = "g1-small"
  worker_type        = "n1-standard-1"
  worker_preemptible = "true"
}
