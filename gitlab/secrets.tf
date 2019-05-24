resource "kubernetes_secret" "gitlab_postgresql_password" {
  metadata {
    name      = "gitlab-postgresql-password"
    namespace = "${kubernetes_namespace.gitlab_ce.metadata.0.name}"
  }

  data = {
    postgres-password = "${var.postgresql_password}"
  }
}

resource "random_id" "gitlab_initial_root_password" {
  byte_length = 8
}

resource "kubernetes_secret" "gitlab_initial_root_password" {
  metadata {
    name      = "${var.helm_release_name}-gitlab-initial-root-password"
    namespace = "${kubernetes_namespace.gitlab_ce.metadata.0.name}"
  }

  data = {
    password = "${random_id.gitlab_initial_root_password.hex}"
  }
}

resource "kubernetes_secret" "gitlab_wildcard_certificate" {
  metadata {
    namespace = "${kubernetes_namespace.gitlab_ce.metadata.0.name}"
    name      = "my-wild-card-certificate"
  }

  type = "kubernetes.io/tls"

  data = {
    "tls.crt" = "${file("${path.module}/certs/jordanpittier.net.cer")}"
    "tls.key" = "${file("${path.module}/certs/jordanpittier.net.key")}"
  }
}

output "gitlab_initial_root_password" {
  value = "${random_id.gitlab_initial_root_password.hex}"
}
