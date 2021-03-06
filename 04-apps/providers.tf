provider "google" {
  version = "~> 3.12"

  credentials = file("../account.json")
  project     = "terraform-playground-237915"
  region      = "europe-west4"
}

provider "helm" {
  version = "~> 0.10"

  kubernetes {
    config_path = pathexpand("~/.secrets/clusters/tf-playground/kubeconfig")
  }
  install_tiller  = false
  service_account = kubernetes_deployment.tiller_with_rbac.spec[0].template[0].spec[0].service_account_name
  namespace       = kubernetes_deployment.tiller_with_rbac.metadata[0].namespace
}

provider "kubernetes" {
  version     = "~> 1.10"
  config_path = pathexpand("~/.secrets/clusters/tf-playground/kubeconfig")
}