terraform {
  backend "gcs" {
    credentials = "../account.json"
    bucket      = "tf-playground-tf-state"
    prefix      = "storage"
  }
}

resource "kubernetes_namespace" "gce_pd_csi" {
  metadata {
    name = "gce-pd-csi"
  }
}

