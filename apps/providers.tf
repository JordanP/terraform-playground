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

  install_tiller  = true
  service_account = kubernetes_service_account.tiller.metadata[0].name
  namespace       = kubernetes_service_account.tiller.metadata[0].namespace
}

provider "kubernetes" {
  config_path = "${local.asset_dir}/auth/kubeconfig"
}

