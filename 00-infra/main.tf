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
  source = "git::https://github.com/poseidon/typhoon//google-cloud/container-linux/kubernetes?ref=4775e9d0f72a7edd7358163d8aa114e1242cc20c"

  # Google Cloud
  cluster_name  = local.cluster_name
  region        = "europe-west4"
  dns_zone      = local.dns_zone
  dns_zone_name = local.dns_zone_name

  # configuration
  ssh_authorized_key = file(pathexpand("~/.ssh/id_rsa.pub"))
  asset_dir          = pathexpand("~/.secrets/clusters/tf-playground")

  # optional
  controller_type    = "n1-standard-1"
  worker_count       = 1
  worker_type        = "n1-standard-2"
  worker_preemptible = true
  worker_node_labels = ["node_type=ingress"]
}

module "google_cloud_jordan_worker_pool" {
  source = "git::https://github.com/poseidon/typhoon//google-cloud/container-linux/kubernetes/workers?ref=4775e9d0f72a7edd7358163d8aa114e1242cc20c"

  # Google Cloud
  region       = "europe-west4"
  network      = module.google_cloud_jordan.network_name
  cluster_name = local.cluster_name

  # configuration
  name               = "default"
  kubeconfig         = module.google_cloud_jordan.kubeconfig
  ssh_authorized_key = file(pathexpand("~/.ssh/id_rsa.pub"))

  # optional
  worker_count = 2
  machine_type = "n1-standard-2"
  preemptible  = true
  node_labels  = ["node_type=default"]
}