provider "google" {
  version = "~> 2.20"

  credentials = file("../account.json")
  project     = "terraform-playground-237915"
  region      = "europe-west4"
}

provider "kubernetes" {
  version     = "~> 1.10"
  config_path = "/home/jordan/.secrets/clusters/tf-playground/auth/kubeconfig"
}