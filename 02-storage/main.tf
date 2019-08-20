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

resource "kubernetes_storage_class" "standard" {
  metadata {
    name = "standard"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
  }
  storage_provisioner = "pd.csi.storage.gke.io"
  parameters = {
    type             = "pd-standard"
    replication-type = "regional-pd"
  }
  volume_binding_mode = "WaitForFirstConsumer"
}

resource "kubernetes_storage_class" "ssd" {
  metadata {
    name = "ssd"
  }
  storage_provisioner = "pd.csi.storage.gke.io"
  parameters = {
    type             = "pd-ssd"
    replication-type = "regional-pd"
  }
  volume_binding_mode = "WaitForFirstConsumer"
}
