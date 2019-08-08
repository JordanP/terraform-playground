resource "kubernetes_namespace" "gitlab_ce" {
  metadata {
    name = "gitlab-ce"

    labels = {
      name = "gitlab-ce"
    }
  }
}
