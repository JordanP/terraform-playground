terraform {
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
  asset_dir           = "/home/jordan/.secrets/clusters/tf-playground"
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
  source         = "./grafana"
  namespace      = kubernetes_namespace.monitoring.metadata[0].name
  hostname       = data.terraform_remote_state.infra.outputs.monitoring_hostname
  kms_crypto_key = data.terraform_remote_state.infra.outputs.my_crypto_key
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
  image         = "rabbitmq:3.7.17"
  replica_count = 3
  disk_size     = 200
  node_selector = null
}

module "postgresql" {
  source                = "./postgres"
  namespace             = "postgres"
  image                 = "postgres:11.5"
  replica_count         = 3
  disk_size             = 20
  master_node_selector  = null
  replica_node_selector = null

  postgresql_conf = <<EOF
listen_addresses = '*'
max_connections = 50
shared_buffers = 1792MB
effective_cache_size = 5376MB
maintenance_work_mem = 448MB
checkpoint_completion_target = 0.7
wal_buffers = 16MB
default_statistics_target = 100
random_page_cost = 1.1
effective_io_concurrency = 200
work_mem = 36700kB
min_wal_size = 1GB
max_wal_size = 2GB
max_worker_processes = 2
max_parallel_workers_per_gather = 1
max_parallel_workers = 2
EOF
}

# terraform destroy -auto-approve -target module.gitlab
module "gitlab" {
  source              = "./gitlab"
  helm_release_name   = local.gitlab_release_name
  postgresql_host     = module.postgresql.postgres_rw_service
  postgresql_database = "postgres"
  postgresql_username = "postgres"
  postgresql_password = module.postgresql.postgres_password
  redis_password      = module.redis.redis_password
  kms_crypto_key      = data.terraform_remote_state.infra.outputs.my_crypto_key
}
