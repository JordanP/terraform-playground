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

# terraform destroy -auto-approve -target module.gitlab
/*module "gitlab" {
  source                = "./gitlab"
  helm_release_name     = local.gitlab_release_name
  postgresql_host       = data.terraform_remote_state.infra.outputs.postgresql_host
  postgresql_database   = data.terraform_remote_state.infra.outputs.postgresql_gitlab_database
  postgresql_password   = data.terraform_remote_state.infra.outputs.postgresql_gitlab_password
  force_destroy_buckets = "true"
  redis_password        = module.redis.redis_password
}*/

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
  source    = "./grafana"
  namespace = kubernetes_namespace.monitoring.metadata[0].name
  hostname  = data.terraform_remote_state.infra.outputs.monitoring_hostname
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
  disk_size     = "10"
  image         = "rabbitmq:3.7.17"
  node_selector = null
}

