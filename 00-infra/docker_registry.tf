resource "google_project_service" "container_registry" {
  service            = "containerregistry.googleapis.com"
  disable_on_destroy = false
}

// Make sure the GCR storage bucket "(eu.)?artifacts.%project%.appspot.com" exists
// Used to ensure that the GCS bucket exists prior to assigning permissions
resource "google_container_registry" "default_us" {
  project = local.project_id
  location = "US"
  depends_on = [google_project_service.container_registry]
}

resource "google_container_registry" "default_eu" {
  project = local.project_id
  location = "EU"
  depends_on = [google_project_service.container_registry]
}
