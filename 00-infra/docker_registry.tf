resource "google_project_service" "container_registry" {
  service            = "containerregistry.googleapis.com"
  disable_on_destroy = false
}

// GCR storage bucket "(eu.)?artifacts.%project%.appspot.com" is created lazily on first push
resource "null_resource" "init_gcr_storage_bucket" {
  for_each = toset(["eu.gcr.io", "gcr.io"])
  provisioner "local-exec" {
    environment = {
      CLOUDSDK_CORE_PROJECT = local.project_id
      CLOUDSDK_CORE_ACCOUNT = "jordan.pittier@gmail.com"
    }
    // Creates a dummy docker image and push it
    command = <<EOF
      # Next line requires that the google cloud SDK is installed from an archive, and not using a package manager.
      # gcloud components install docker-credential-gcr && docker-credential-gcr configure-docker && \
      # If using a package manager:
      gcloud auth configure-docker && \
      (echo 'FROM scratch'; echo 'LABEL maintainer=jordan.pittier') | \
      docker build -t ${each.key}/${local.project_id}/scratch:latest - && \
      docker push ${each.key}/${local.project_id}/scratch:latest
      EOF
  }
  depends_on = [google_project_service.container_registry]
}
