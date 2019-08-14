provider "google" {
  version = "2.9.0"

  credentials = file("../account.json")
  project     = "terraform-playground-237915"
  region      = "europe-west4"
}

provider "helm" {
  version = "~> 0.10"

  kubernetes {
    config_path = "${local.asset_dir}/auth/kubeconfig"
  }
  install_tiller  = false
  service_account = kubernetes_deployment.tiller_with_rbac.spec[0].template[0].spec[0].service_account_name
  namespace       = kubernetes_deployment.tiller_with_rbac.metadata[0].namespace
}

provider "kubernetes" {
  config_path = "${local.asset_dir}/auth/kubeconfig"
}

terraform {
  required_version = ">= 0.12"
}
