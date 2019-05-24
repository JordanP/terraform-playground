data "helm_repository" "gitlab" {
  name = "gitlab"
  url  = "https://charts.gitlab.io/"
}

resource "helm_release" "gitlab" {
  name       = "${var.helm_release_name}"
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
    value = "${var.postgresql_host}"
  }

  set {
    name  = "global.psql.database"
    value = "${var.postgresql_database}"
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

  // https://gitlab.com/charts/gitlab/blob/master/doc/installation/tls.md#option-2-use-your-own-wildcard-certificate
  // gcloud config configurations list && export CLOUDSDK_ACTIVE_CONFIG_NAME=default
  // acme.sh --issue --dns dns_gcloud -d jordanpittier.net -d '*.jordanpittier.net'
  set {
    name  = "certmanager.install"
    value = "false"
  }

  set {
    name  = "global.ingress.configureCertmanager"
    value = "false"
  }

  set {
    name  = "global.ingress.tls.secretName"
    value = "${kubernetes_secret.gitlab_wildcard_certificate.metadata.0.name}"
  }
}
