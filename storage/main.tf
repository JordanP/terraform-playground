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

resource "kubernetes_storage_class" "csi_gce_pd" {
  metadata {
    name = "csi-gce-pd"
    annotations = {
      "storageclass.kubernetes.io/is-default-class":"true"
    }
  }
  storage_provisioner = "pd.csi.storage.gke.io"
  parameters = {
    type = "pd-standard"
  }
  volume_binding_mode = "WaitForFirstConsumer"
}