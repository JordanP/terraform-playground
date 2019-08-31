provider "google" {
  version = "2.13.0"

  credentials = file("../account.json")
  project     = "terraform-playground-237915"
  region      = "europe-west4"
}

provider "kubernetes" {
  #version     = "0.0.0"
  config_path = "/home/jordan/.secrets/clusters/tf-playground/auth/kubeconfig"
}

terraform {
  required_version = ">= 0.12"
}
