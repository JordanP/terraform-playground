resource "random_id" "randomSuffix" {
  byte_length = 4
}

locals {
  needed_roles = [
    "roles/compute.storageAdmin",
    "roles/iam.serviceAccountUser",
    "projects/terraform-playground-237915/roles/${google_project_iam_custom_role.gcp_compute_persistent_disk_csi_driver_custom_role.role_id}"
  ]
}

resource "google_project_iam_custom_role" "gcp_compute_persistent_disk_csi_driver_custom_role" {
  role_id     = "gcpComputePersistentDiskCSIDriverCustomRole${random_id.randomSuffix.hex}"
  title       = "GCP Compute Persistent Disk CSI Driver Custom Roles"
  description = "Custom roles required for functions of the gcp-compute-persistent-disk-csi-driver"
  permissions = [
    "compute.instances.get",
    "compute.instances.attachDisk",
    "compute.instances.detachDisk",
  ]
}

resource "google_service_account" "my_gce_pd_csi_sa" {
  account_id = "my-gce-pd-csi-sa"
}

resource "google_project_iam_member" "project" {
  count   = length(local.needed_roles)
  project = "terraform-playground-237915"
  role    = local.needed_roles[count.index]
  member  = "serviceAccount:${google_service_account.my_gce_pd_csi_sa.email}"
}

resource "google_service_account_key" "default" {
  service_account_id = google_service_account.my_gce_pd_csi_sa.account_id
}

resource "kubernetes_secret" "cloud_sa" {
  metadata {
    name      = "cloud-sa"
    namespace = kubernetes_namespace.gce_pd_csi.metadata.0.name
  }
  data = {
    "cloud-sa.json" = base64decode(google_service_account_key.default.private_key)
  }
}

resource "kubernetes_service_account" "csi_gce_pd_node_sa" {
  automount_service_account_token = true
  metadata {
    name      = "csi-gce-pd-node-sa"
    namespace = kubernetes_namespace.gce_pd_csi.metadata.0.name
  }
}

resource "kubernetes_cluster_role" "driver_registrar_role" {
  metadata {
    name = "driver-registrar-role"
  }
  rule {
    verbs      = ["get", "list", "watch", "create", "update", "patch"]
    api_groups = [""]
    resources  = ["events"]
  }
}

resource "kubernetes_cluster_role_binding" "driver_registrar_binding" {
  metadata {
    name = "driver-registrar-binding"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.driver_registrar_role.metadata.0.name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.csi_gce_pd_node_sa.metadata.0.name
    namespace = kubernetes_namespace.gce_pd_csi.metadata.0.name
  }
}

resource "kubernetes_service_account" "csi_controller_sa" {
  automount_service_account_token = true
  metadata {
    name      = "csi-gce-pd-controller-sa"
    namespace = kubernetes_namespace.gce_pd_csi.metadata.0.name
  }
}

resource "kubernetes_cluster_role" "external_provisioner_role" {
  metadata {
    name = "csi-gce-pd-provisioner-role"
  }
  rule {
    verbs      = ["get", "list", "watch", "create", "delete"]
    resources  = ["persistentvolumes"]
    api_groups = [""]
  }
  rule {
    verbs      = ["get", "list", "watch", "update"]
    resources  = ["persistentvolumeclaims"]
    api_groups = [""]

  }
  rule {
    verbs      = ["get", "list", "watch"]
    resources  = ["storageclasses"]
    api_groups = ["storage.k8s.io"]
  }
  rule {
    api_groups = [""]
    resources  = ["events"]
    verbs      = ["list", "watch", "create", "update", "patch"]
  }
  rule {
    api_groups = ["storage.k8s.io"]
    resources  = ["csinodes"]
    verbs      = ["get", "list", "watch"]
  }
  rule {
    api_groups = [""]
    resources  = ["nodes"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_cluster_role_binding" "csi_controller_provisioner_binding" {
  metadata {
    name = "csi-gce-pd-controller-provisioner-binding"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.external_provisioner_role.metadata.0.name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.csi_controller_sa.metadata.0.name
    namespace = kubernetes_namespace.gce_pd_csi.metadata.0.name
  }
}

resource "kubernetes_cluster_role" "external_attacher_role" {
  metadata {
    name = "csi-gce-pd-attacher-role"
  }
  rule {
    api_groups = [""]
    resources  = ["persistentvolumes"]
    verbs      = ["get", "list", "watch", "update", "patch"]
  }
  rule {
    api_groups = [""]
    resources  = ["nodes"]
    verbs      = ["get", "list", "watch"]
  }
  rule {
    api_groups = ["storage.k8s.io"]
    resources  = ["csinodes"]
    verbs      = ["get", "list", "watch"]
  }
  rule {
    api_groups = ["storage.k8s.io"]
    resources  = ["volumeattachments"]
    verbs      = ["get", "list", "watch", "update", "patch"]
  }
  rule {
    api_groups = ["storage.k8s.io"]
    resources  = ["volumeattachments/status"]
    verbs      = ["patch"]
  }
}

resource "kubernetes_cluster_role_binding" "csi_controller_attacher_binding" {
  metadata {
    name = "csi-gce-pd-controller-attacher-binding"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.external_attacher_role.metadata.0.name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.csi_controller_sa.metadata.0.name
    namespace = kubernetes_namespace.gce_pd_csi.metadata.0.name
  }
}

// Resizer must be able to work with PVCs, PVs, SCs.
resource "kubernetes_cluster_role" "csi_gce_pd_resizer_role" {
  metadata {
    name = "csi-gce-pd-resizer-role"
  }
  rule {
    verbs      = ["get", "list", "watch", "update", "patch"]
    api_groups = [""]
    resources  = ["persistentvolumes"]
  }
  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = [""]
    resources  = ["persistentvolumeclaims"]
  }
  rule {
    verbs      = ["update", "patch"]
    resources  = ["persistentvolumeclaims/status"]
    api_groups = [""]
  }
  rule {
    verbs      = ["list", "watch", "create", "update", "patch"]
    resources  = ["events"]
    api_groups = [""]
  }
}

resource "kubernetes_cluster_role_binding" "csi_gce_pd_resizer_binding" {
  metadata {
    name = "csi-gce-pd-resizer-binding"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.csi_gce_pd_resizer_role.metadata.0.name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.csi_controller_sa.metadata.0.name
    namespace = kubernetes_service_account.csi_controller_sa.metadata.0.namespace
  }
}

resource "kubernetes_cluster_role" "csi_gce_pd_node_deploy" {
  metadata {
    name = "csi-gce-pd-node-deploy"
  }
  rule {
    verbs          = ["use"]
    api_groups     = ["policy"]
    resources      = ["podsecuritypolicies"]
    resource_names = ["csi-gce-pd-node-psp"]
  }
}

resource "kubernetes_cluster_role_binding" "csi_gce_pd_node" {
  metadata {
    name = "csi-gce-pd-node"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.csi_gce_pd_node_deploy.metadata.0.name
  }
  subject {
    kind = "ServiceAccount"
    name = kubernetes_service_account.csi_gce_pd_node_sa.metadata.0.name
  }
}