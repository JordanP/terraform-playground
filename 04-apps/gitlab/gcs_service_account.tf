resource "google_service_account" "gitlab_storage" {
  account_id   = "gitlab-storage"
  display_name = "Gitlab GCS"
}

resource "google_service_account_key" "gitlab_storage" {
  service_account_id = google_service_account.gitlab_storage.id
}

locals {
  registry-bucket = "gitlab-registry-storage"

  other-buckets = [
    "gitlab-lfs-storage",
    "gitlab-artifacts-storage",
    "gitlab-uploads-storage",
    "gitlab-packages-storage",
    "gitlab-backup-storage",
    "gitlab-tmp-storage",
    "gitlab-cache-storage",
  ]

  all-buckets = concat(local.other-buckets, list(local.registry-bucket))
}

resource "google_storage_bucket" "gitlab_storage" {
  count         = length(local.all-buckets)
  name          = "${element(local.all-buckets, count.index)}-jpittier"
  location      = "europe-west4"
  storage_class = "REGIONAL"
  force_destroy = var.force_destroy_buckets
}

resource "google_storage_bucket_iam_member" "gitlab_object_admin" {
  count  = length(local.all-buckets)
  bucket = google_storage_bucket.gitlab_storage[count.index].name
  member = "serviceAccount:${google_service_account.gitlab_storage.email}"
  role   = "roles/storage.objectAdmin"
}
