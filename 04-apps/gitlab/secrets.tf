resource "kubernetes_secret" "redis_password" {
  metadata {
    name      = "gitlab-redis-password"
    namespace = kubernetes_namespace.gitlab_ce.metadata[0].name
  }
  data = {
    secret = var.redis_password
  }
}

resource "kubernetes_secret" "gitlab_postgresql_password" {
  metadata {
    name      = "gitlab-postgresql-password"
    namespace = kubernetes_namespace.gitlab_ce.metadata[0].name
  }

  data = {
    postgres-password = var.postgresql_password
  }
}

resource "random_id" "gitlab_initial_root_password" {
  byte_length = 8
}

resource "kubernetes_secret" "gitlab_initial_root_password" {
  metadata {
    name      = "${var.helm_release_name}-gitlab-initial-root-password"
    namespace = kubernetes_namespace.gitlab_ce.metadata[0].name
  }

  data = {
    password = random_id.gitlab_initial_root_password.hex
  }
}

resource "random_id" "wildcard_certificate_name_suffix" {
  byte_length = 4

  keepers = {
    "tls.crt" = base64sha256(file("${path.module}/../certs/jordanpittier.net.cer"))
    "tls.key" = base64sha256(file("${path.module}/../certs/jordanpittier.net.key"))
  }
}

resource "kubernetes_secret" "wildcard_certificate" {
  metadata {
    namespace = kubernetes_namespace.gitlab_ce.metadata[0].name
    name      = "wildcard-jordanpittier-net-${random_id.wildcard_certificate_name_suffix.hex}"
  }

  type = "kubernetes.io/tls"

  data = {
    "tls.crt" = file("${path.module}/../certs/jordanpittier.net.cer")
    "tls.key" = file("${path.module}/../certs/jordanpittier.net.key")
  }
}

data "template_file" "registry_storage" {
  template = file("${path.module}/storage/registry.yml.tpl")

  vars = {
    bucket_name = "${local.registry-bucket}-jpittier"
  }
}

data "template_file" "other_storage" {
  template = file("${path.module}/storage/other.yml.tpl")

  vars = {
    google_project_id      = "terraform-playground-237915"
    google_client_email    = google_service_account.gitlab_storage.email
    google_json_key_string = indent(2, base64decode(google_service_account_key.gitlab_storage.private_key))
  }
}

locals {
  # https://console.cloud.google.com/storage/settings -> Interoperability
  access_key = "GOOGLGQBY3UGMNCCUB4RLIXQ"
  secret_key = "xxxx"
}

data template_file "s3cfg" {
  template = file("${path.module}/storage/s3cfg.tpl")

  vars = {
    access_key = local.access_key
    secret_key = local.secret_key
  }
}

resource "random_id" "gitlab_gcs_storage_secret_name_suffix" {
  byte_length = 4

  keepers = {
    config = data.template_file.registry_storage.rendered
    # registry.storage
    keyfile    = base64decode(google_service_account_key.gitlab_storage.private_key)
    connection = data.template_file.other_storage.rendered
    # global.appConfig.*.connection
    gcs-access-id = local.access_key
    # gitlab-runner.runners.cache
    gcs-private-key = local.secret_key
    # gitlab-runner.runners.cache
    s3cfg-config = data.template_file.s3cfg.rendered
    # gitlab.task-runner.backups.objectStorage.config.key
  }
}

resource "kubernetes_secret" "gitlab_gcs_storage" {
  metadata {
    name      = "gcs-storage-${random_id.gitlab_gcs_storage_secret_name_suffix.hex}"
    namespace = kubernetes_namespace.gitlab_ce.metadata.0.name
  }

  data = random_id.gitlab_gcs_storage_secret_name_suffix.keepers
}

output "gitlab_initial_root_password" {
  value = random_id.gitlab_initial_root_password.hex
}
