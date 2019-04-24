resource "kubernetes_cluster_role" "prometheus" {
  metadata {
    name = "prometheus"
  }

  rule {
    api_groups = [
      "",
    ]

    resources = [
      "nodes",
      "nodes/metrics",
      "services",
      "endpoints",
      "pods",
    ]

    verbs = [
      "get",
      "list",
      "watch",
    ]
  }

  rule {
    non_resource_urls = ["/metrics"]

    verbs = [
      "get",
    ]
  }
}
