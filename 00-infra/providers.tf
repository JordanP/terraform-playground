provider "google" {
  version = "~> 2.13"

  credentials = file("../account.json")
  project     = "terraform-playground-237915"
  region      = "europe-west4"
}


provider "ct" {
  version = "0.4.0"
}

provider "acme" {
  version = "~> 1.4"

  server_url = "https://acme-v02.api.letsencrypt.org/directory"
}