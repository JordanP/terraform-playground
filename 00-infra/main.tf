terraform {
  required_version = ">= 0.12"

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
}

resource "google_compute_firewall" "git_clone_ssh" {
  name    = "git-clone-ssh"
  network = module.google_cloud_jordan.network_name

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
  target     = module.google_cloud_jordan.worker_target_pool
  port_range = "1-65535"
}

module "google_cloud_jordan" {
  source = "git::https://github.com/poseidon/typhoon//google-cloud/container-linux/kubernetes?ref=e71e27e7696903eb3b10cb30ec267233ae6d771a"

  # Google Cloud
  os_image      = "coreos-stable"
  cluster_name  = local.cluster_name
  region        = "europe-west4"
  dns_zone      = local.dns_zone
  dns_zone_name = local.dns_zone_name

  # configuration
  ssh_authorized_key = file(pathexpand("~/.ssh/id_rsa.pub"))

  # optional
  controller_type    = "e2-small"
  worker_count       = 3
  worker_type        = "e2-medium"
  worker_preemptible = true
  worker_node_labels = ["node_type=standard"]
}

# Obtain cluster kubeconfig
resource "local_file" "kubeconfig_jordan" {
  content  = module.google_cloud_jordan.kubeconfig-admin
  filename = pathexpand("~/.secrets/clusters/tf-playground/kubeconfig")
}