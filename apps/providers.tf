provider "google" {
  version = "~> 2.3.0"
  alias   = "default"

  credentials = "${file("../account.json")}"
  project     = "terraform-playground-237915"
  region      = "europe-west4"
}

provider "helm" {
  version = "~> 0.9"

  kubernetes {
    config_path = "${local.asset_dir}/auth/kubeconfig"
  }

  install_tiller  = "true"
  service_account = "${kubernetes_service_account.tiller.metadata.0.name}"
  namespace       = "kube-system"
}

provider "kubernetes" {
  config_path = "${local.asset_dir}/auth/kubeconfig"
}
