resource "helm_release" "gitlab" {
  name       = "${local.gitlab_release_name}"
  repository = "${data.helm_repository.gitlab.metadata.0.name}"
  chart      = "gitlab"
  timeout    = 600
  namespace  = "${kubernetes_namespace.gitlab_ce.metadata.0.name}"

  set {
    name  = "global.hosts.domain"
    value = "jordanpittier.net"
  }

  set {
    name  = "global.edition"
    value = "ce"
  }

  set {
    name  = "certmanager-issuer.email"
    value = "jordan@rezel.net"
  }

  set {
    name  = "nginx-ingress.enabled"
    value = "false"
  }

  set {
    name  = "global.ingress.class"
    value = "public"
  }

  set {
    name  = "prometheus.install"
    value = "false"
  }

  set {
    name  = "redis.persistence.enabled"
    value = "false"
  }

  set {
    name  = "minio.persistence.enabled"
    value = "false"
  }

  set {
    name  = "gitlab.gitaly.persistence.enabled"
    value = "false"
  }

  set {
    name  = "gitlab.unicorn.minReplicas"
    value = "1"
  }

  set {
    name  = "gitlab.gitlab-shell.minReplicas"
    value = "1"
  }

  set {
    name  = "registry.minReplicas"
    value = "1"
  }

  set {
    name  = "postgresql.install"
    value = "false"
  }

  set {
    name  = "global.psql.host"
    value = "${google_sql_database_instance.default.first_ip_address}"
  }

  set {
    name  = "global.psql.database"
    value = "${google_sql_database.gitlab_db.name}"
  }

  set {
    name  = "global.psql.password.secret"
    value = "${kubernetes_secret.gitlab_postgresql_password.metadata.0.name}"
  }

  set {
    name  = "global.psql.password.key"
    value = "postgres-password"
  }

  set {
    name  = "global.shell.port"
    value = "8022"
  }

  // Required for Docker in Docker (DinD)
  set {
    name  = "gitlab-runner.runners.privileged"
    value = "true"
  }

  // https://gitlab.com/charts/gitlab/issues/1272#note_158005007
  set {
    name  = "certmanager-issuer.image.repository"
    value = "gcr.io/google_containers/hyperkube"
  }

  set {
    name  = "certmanager-issuer.image.tag"
    value = "v1.14.0"
  }
}

resource "kubernetes_namespace" "gitlab_ce" {
  metadata {
    name = "gitlab-ce"

    labels {
      name = "gitlab-ce"
    }
  }
}

resource "kubernetes_secret" "gitlab_postgresql_password" {
  metadata {
    name      = "gitlab-postgresql-password"
    namespace = "${kubernetes_namespace.gitlab_ce.metadata.0.name}"
  }

  data = {
    postgres-password = "${random_id.postgres_gitlab_password.hex}"
  }
}

resource "random_id" "gitlab_initial_root_password" {
  byte_length = 8
}

resource "kubernetes_secret" "gitlab_initial_root_password" {
  metadata {
    name      = "${local.gitlab_release_name}-gitlab-initial-root-password"
    namespace = "${kubernetes_namespace.gitlab_ce.metadata.0.name}"
  }

  data = {
    password = "${random_id.gitlab_initial_root_password.hex}"
  }
}

resource "google_compute_firewall" "git_clone_ssh" {
  provider = "google.default"
  name     = "git-clone-ssh"
  network  = "${module.google-cloud-jordan.network_name}"

  allow {
    protocol = "TCP"

    ports = [
      8022,
    ]
  }

  target_tags = ["${local.cluster_name}-worker"]
}

resource "google_compute_forwarding_rule" "gitlab" {
  provider   = "google.default"
  name       = "gitlab"
  target     = "${module.google-cloud-jordan.worker_target_pool}"
  port_range = "1-65535"
}

output "gitlab_initial_root_password" {
  value = "${random_id.gitlab_initial_root_password.hex}"
}
