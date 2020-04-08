locals {
  project_id = "terraform-playground-237915"
}

provider "kubernetes" {
  version     = "~> 1.10"
  config_path = pathexpand("~/.secrets/clusters/tf-playground/kubeconfig")
}

data "terraform_remote_state" "apps" {
  backend = "gcs"

  config = {
    credentials = "../account.json"
    bucket      = "tf-playground-tf-state"
    prefix      = "apps"
  }
}

resource "kubernetes_secret" "docker_credentials" {
  metadata {
    name = "docker-cfg"
  }
  type = "kubernetes.io/dockerconfigjson"
  data = {
    ".dockerconfigjson" = <<EOF
{
  "auths": {
    "eu.gcr.io": {
      "email": "not@val.id",
      "auth": "${base64encode("_json_key:${file("../account.json")}")}"
    }
  }
}
EOF
  }
}

resource "null_resource" "docker" {
  triggers = {
    "main.go" = filebase64sha256("main.go")
  }
  provisioner "local-exec" {
    command = "docker build -t eu.gcr.io/${local.project_id}/pinger:latest ."
  }
  provisioner "local-exec" {
    # ~/.docker/config.json has "credHelpers" set to gcloud, hence the environment variable here are relevant.
    environment = {
      CLOUDSDK_CORE_PROJECT = local.project_id
      CLOUDSDK_CORE_ACCOUNT = "jordan.pittier@gmail.com"
    }
    command = "docker push eu.gcr.io/${local.project_id}/pinger"
  }
}

resource "random_id" "config" {
  byte_length = 4
  keepers = {
    HTTP_URL   = "https://google.fr"
    REDIS_ADDR = "redis.default:6379"
  }
}

resource "random_id" "secret" {
  byte_length = 4
  keepers = {
    REDIS_PASSWD = data.terraform_remote_state.apps.outputs.redis_password
    PG_DSN       = "postgres://postgres:${data.terraform_remote_state.apps.outputs.postgres_password}@pg-bouncer.postgres/?sslmode=disable"
  }
}

resource "kubernetes_config_map" "test" {
  metadata {
    name = "pinger-${random_id.config.hex}"
  }
  data = random_id.config.keepers
}

resource "kubernetes_secret" "test" {
  metadata {
    name = "pinger-${random_id.config.hex}"
  }
  data = random_id.secret.keepers
}

resource "kubernetes_pod" "test" {
  metadata {
    name = "test-2"
  }
  spec {
    image_pull_secrets {
      name = kubernetes_secret.docker_credentials.metadata.0.name
    }
    container {
      name              = "pinger"
      image             = "eu.gcr.io/${local.project_id}/pinger:latest"
      image_pull_policy = "Always"
      env_from {
        config_map_ref {
          name = kubernetes_config_map.test.metadata.0.name
        }
      }
      env_from {
        secret_ref {
          name = kubernetes_secret.test.metadata.0.name
        }
      }
    }
  }
}
