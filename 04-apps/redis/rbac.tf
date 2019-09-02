resource "kubernetes_service_account" "redis" {
  metadata {
    name = "redis"
    labels = {
      app = "redis"
    }
  }
}