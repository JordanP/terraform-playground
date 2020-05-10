locals {
  # Infer the value based on the version set in the docker image name
  pgmajor = regex("postgres:([0-9]+)", var.image)[0]
}

resource "kubernetes_namespace" "postgresql" {
  count = (var.namespace != "default" ? 1 : 0)
  metadata {
    name = var.namespace
  }
}
