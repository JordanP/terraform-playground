data "helm_repository" "gitlab" {
  name = "gitlab"
  url  = "https://charts.gitlab.io/"
}

locals {
  env_variables = {
    "certmanager.install" : "false"
    "certmanager-issuer.email" : "jordan@rezel.net"
    #"certmanager-issuer.image.repository" : "gcr.io/google_containers/hyperkube"
    #"certmanager-issuer.image.tag" : "v1.14.0"
    "gitlab.gitaly.persistence.enabled" : "false"
    "gitlab.gitlab-shell.minReplicas" : "1"
    "gitlab-runner.runners.cache.cacheType" : "gcs"
    "gitlab-runner.runners.cache.gcsBucketName" : "gitlab-cache-storage-jpittier"
    "gitlab-runner.runners.cache.secretName" : kubernetes_secret.gitlab_gcs_storage.metadata[0].name
    "gitlab-runner.runners.privileged" : "true"
    "gitlab.task-runner.backups.objectStorage.config.key" : "s3cfg-config"
    "gitlab.task-runner.backups.objectStorage.config.secret" : kubernetes_secret.gitlab_gcs_storage.metadata[0].name
    "gitlab.unicorn.minReplicas" : "1"
    "global.appConfig.artifacts.bucket" : "gitlab-artifacts-storage-jpittier"
    "global.appConfig.artifacts.connection.secret" : kubernetes_secret.gitlab_gcs_storage.metadata[0].name
    "global.appConfig.backups.bucket" : "gitlab-backup-storage-jpittier"
    "global.appConfig.backups.tmpBucket" : "gitlab-tmp-storage-jpittier"
    "global.appConfig.lfs.bucket" : "gitlab-lfs-storage-jpittier"
    "global.appConfig.lfs.connection.secret" : kubernetes_secret.gitlab_gcs_storage.metadata[0].name
    "global.appConfig.packages.bucket" : "gitlab-packages-storage-jpittier"
    "global.appConfig.packages.connection.secret" : kubernetes_secret.gitlab_gcs_storage.metadata[0].name
    "global.appConfig.registry.bucket" : "gitlab-registry-storage-jpittier"
    "global.appConfig.uploads.bucket" : "gitlab-uploads-storage-jpittier"
    "global.appConfig.uploads.connection.secret" : kubernetes_secret.gitlab_gcs_storage.metadata[0].name
    "global.edition" : "ce"
    "global.hosts.domain" : "jordanpittier.net"
    "global.hosts.https" : "true"
    "global.hosts.gitlab.https" : "true"
    "global.ingress.class" : "public"
    "global.ingress.configureCertmanager" : "false"
    "global.ingress.tls.secretName" : kubernetes_secret.wildcard_certificate.metadata[0].name
    "global.minio.enabled" : "false"
    "global.psql.database" : var.postgresql_database
    "global.psql.host" : var.postgresql_host
    "global.psql.password.key" : "postgres-password"
    "global.psql.password.secret" : kubernetes_secret.gitlab_postgresql_password.metadata[0].name
    "global.psql.username" : var.postgresql_username
    "global.redis.host" : "redis.default"
    "global.redis.password.key" : "secret"
    "global.redis.password.secret" : kubernetes_secret.redis_password.metadata.0.name
    "global.shell.port" : "8022"
    "minio.persistence.enabled" : "false"
    "nginx-ingress.enabled" : "false"
    "postgresql.install" : "false"
    "prometheus.install" : "false"
    "redis.enabled" : "false"
    "registry.hpa.minReplicas" : "1"
    "registry.storage.extraKey" : "keyfile"
    "registry.storage.key" : "config"
    "registry.storage.secret" : kubernetes_secret.gitlab_gcs_storage.metadata[0].name

  }
}


resource "helm_release" "gitlab" {
  name       = var.helm_release_name
  repository = data.helm_repository.gitlab.metadata[0].name
  version    = "2.5.9"
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
