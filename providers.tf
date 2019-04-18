provider "google" {
  version = "~> 2.3.0"
  alias   = "default"

  credentials = "${file("account.json")}"
  project     = "terraform-playground-237915"
  region      = "europe-west4"
}

provider "ct" {
  version = "0.3.1"
}

provider "local" {
  version = "~> 1.0"
  alias   = "default"
}

provider "null" {
  version = "~> 1.0"
  alias   = "default"
}

provider "template" {
  version = "~> 1.0"
  alias   = "default"
}

provider "tls" {
  version = "~> 1.0"
  alias   = "default"
}

provider "kubernetes" {
  config_path = "${local.asset_dir}/auth/kubeconfig"
}
