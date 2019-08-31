provider "google" {
  version = "2.13.0"

  credentials = file("../account.json")
  project     = "terraform-playground-237915"
  region      = "europe-west4"
}


provider "ct" {
  version = "0.3.2"
}

terraform {
  required_version = ">= 0.12"
}
