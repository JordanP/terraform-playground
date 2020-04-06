provider "google" {
  version = "~> 3.12"

  credentials = file("../account.json")
  project     = "terraform-playground-237915"
  region      = "europe-west4"
}


provider "ct" {
  version = "0.5.0"
}

provider "acme" {
  version = "~> 1.4"

  server_url = "https://acme-v02.api.letsencrypt.org/directory"
}