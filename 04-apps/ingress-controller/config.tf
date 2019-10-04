resource "random_id" "cm_suffix" {
  byte_length = 4
  keepers = {
    "server-tokens" = "false"
  }
}

resource "kubernetes_config_map" "nginx_configuration" {
  metadata {
    name      = "nginx-configuration-${random_id.cm_suffix.hex}"
    namespace = (var.namespace != "default" ? kubernetes_namespace.ingress[0].metadata.0.name : "default")
  }
  data = random_id.cm_suffix.keepers
}

resource "kubernetes_config_map" "tcp_services" {
  metadata {
    name      = "tcp-services"
    namespace = (var.namespace != "default" ? kubernetes_namespace.ingress[0].metadata.0.name : "default")
  }
  data = {
    "8022" = "gitlab-ce/${var.gitlab_release_name}-gitlab-shell:22"
  }
}