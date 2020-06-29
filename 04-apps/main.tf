terraform {
  required_version = ">= 0.12"

  backend "gcs" {
    credentials = "../account.json"
    bucket      = "tf-playground-tf-state"
    prefix      = "apps"
  }
}

data "terraform_remote_state" "infra" {
  backend = "gcs"

  config = {
    credentials = "../account.json"
    bucket      = "tf-playground-tf-state"
    prefix      = "infra"
  }
}

locals {
  gitlab_release_name = "my-gitlab"
}


resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"

    labels = {
      name = "monitoring"
    }
  }
}

module "nginx" {
  source              = "./ingress-controller"
  gitlab_release_name = local.gitlab_release_name
}

module "grafana" {
  source          = "./grafana"
  namespace       = kubernetes_namespace.monitoring.metadata[0].name
  hostname        = data.terraform_remote_state.infra.outputs.monitoring_hostname
  tls_certificate = data.terraform_remote_state.infra.outputs.certificate
  tls_private_key = data.terraform_remote_state.infra.outputs.private_key
}

module "prometheus" {
  source    = "./prometheus"
  namespace = kubernetes_namespace.monitoring.metadata[0].name
}

module "redis" {
  source = "./redis"
}

module "rabbitmq" {
  source        = "./rabbitmq"
  namespace     = "rabbitmq"
  image         = "rabbitmq:3.7.26"
  replica_count = 3
  disk_size     = 200
  node_selector = null
}

module "postgresql" {
  source                = "./postgres"
  namespace             = "postgres"
  image                 = "postgres:12.3"
  replica_count         = 1
  disk_size             = 20
  primary_node_selector = null
  replica_node_selector = null

  postgresql_conf_template           = abspath("postgres/files/postgresql.conf.tpl")
  postgresql_primary_max_connections = 50
  postgresql_primary_work_mem        = "36700kB"
  # Needs to be higher than primary:
  # hot standby is not possible because max_connections = XX is a lower setting than on the master server
  postgresql_replica_max_connections = 60
  postgresql_replica_work_mem        = "30MB"
}

module "pgbouncer" {
  source                       = "./pgbouncer"
  namespace                    = "postgres"
  pg_primary_hostname          = module.postgresql.postgres_rw_service
  pg_primary_postgres_password = module.postgresql.postgres_password
  max_client_conn              = 100
}

# terraform destroy -auto-approve -target module.gitlab
//module "gitlab" {
//  source              = "./gitlab"
//  helm_release_name   = local.gitlab_release_name
//  postgresql_host     = module.postgresql.postgres_rw_service
//  postgresql_database = "postgres"
//  postgresql_username = "postgres"
//  postgresql_password = module.postgresql.postgres_password
//  redis_password      = module.redis.redis_password
//  tls_certificate     = data.terraform_remote_state.infra.outputs.certificate
//  tls_private_key     = data.terraform_remote_state.infra.outputs.private_key
//}

output "redis_password" {
  value     = module.redis.redis_password
  sensitive = true
}

output "postgres_password" {
  value     = module.postgresql.postgres_password
  sensitive = true
}
