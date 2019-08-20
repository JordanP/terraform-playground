data "helm_repository" "gitlab" {
  name = "gitlab"
  url  = "https://charts.gitlab.io/"
}

locals {
  env_variables = {
    "global.hosts.domain" : "jordanpittier.net"
    "global.edition" : "ce"
    "certmanager-issuer.email" : "jordan@rezel.net"
    "nginx-ingress.enabled" : "false"
    "global.ingress.class" : "public"
    "prometheus.install" : "false"
    "redis.enabled" : "false"
    "global.redis.host" : "redis.default"
    "global.redis.password.secret" : kubernetes_secret.redis_password.metadata.0.name
    "global.redis.password.key" : "secret"
    "minio.persistence.enabled" : "false"
    "gitlab.gitaly.persistence.enabled" : "false"
    "gitlab.unicorn.minReplicas" : "1"
    "gitlab.gitlab-shell.minReplicas" : "1"
    "registry.minReplicas" : "1"
    "postgresql.install" : "false"
    "global.psql.host" : var.postgresql_host
    "global.psql.database" : var.postgresql_database
    "global.psql.username" : var.postgresql_username
    "global.psql.password.secret" : kubernetes_secret.gitlab_postgresql_password.metadata[0].name
    "global.psql.password.key" : "postgres-password"
    "global.shell.port" : "8022"
    "gitlab-runner.runners.privileged" : "true"
    "certmanager-issuer.image.repository" : "gcr.io/google_containers/hyperkube"
    "certmanager-issuer.image.tag" : "v1.14.0"
    "certmanager.install" : "false"
    "global.ingress.configureCertmanager" : "false"
    "global.ingress.tls.secretName" : kubernetes_secret.gitlab_wildcard_certificate.metadata[0].name
    "registry.storage.secret" : kubernetes_secret.gitlab_gcs_storage.metadata[0].name
    "registry.storage.key" : "config"
    "registry.storage.extraKey" : "keyfile"
    "global.minio.enabled" : "false"
    "global.appConfig.lfs.bucket" : "gitlab-lfs-storage-jpittier"
    "global.appConfig.lfs.connection.secret" : kubernetes_secret.gitlab_gcs_storage.metadata[0].name
    "global.appConfig.artifacts.bucket" : "gitlab-artifacts-storage-jpittier"
    "global.appConfig.artifacts.connection.secret" : kubernetes_secret.gitlab_gcs_storage.metadata[0].name
    "global.appConfig.uploads.bucket" : "gitlab-uploads-storage-jpittier"
    "global.appConfig.uploads.connection.secret" : kubernetes_secret.gitlab_gcs_storage.metadata[0].name
    "global.appConfig.packages.bucket" : "gitlab-packages-storage-jpittier"
    "global.appConfig.packages.connection.secret" : kubernetes_secret.gitlab_gcs_storage.metadata[0].name
    "global.appConfig.registry.bucket" : "gitlab-registry-storage-jpittier"
    "global.appConfig.backups.bucket" : "gitlab-backup-storage-jpittier"
    "global.appConfig.backups.tmpBucket" : "gitlab-tmp-storage-jpittier"
    "gitlab.task-runner.backups.objectStorage.config.secret" : kubernetes_secret.gitlab_gcs_storage.metadata[0].name
    "gitlab.task-runner.backups.objectStorage.config.key" : "s3cfg-config"
    "gitlab-runner.runners.cache.cacheType" : "gcs"
    "gitlab-runner.runners.cache.gcsBucketName" : "gitlab-cache-storage-jpittier"
    "gitlab-runner.runners.cache.secretName" : kubernetes_secret.gitlab_gcs_storage.metadata[0].name
  }
}


resource "helm_release" "gitlab" {
  name       = var.helm_release_name
  repository = data.helm_repository.gitlab.metadata[0].name
  version    = "1.9.6"
  chart      = "gitlab"
  timeout    = 600
  namespace  = kubernetes_namespace.gitlab_ce.metadata[0].name

  dynamic "set" {
    for_each = local.env_variables
    content {
      name  = set.key
      value = set.value
    }
  }
}
