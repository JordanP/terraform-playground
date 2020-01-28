resource "kubernetes_service" "kube_proxy" {
  metadata {
    name      = "kube-proxy"
    namespace = "kube-system"

    annotations = {
      "prometheus.io/scrape" = "true"
      "prometheus.io/port"   = "10249"
    }
  }

  spec {
    type       = "ClusterIP"
    cluster_ip = "None"

    selector = {
      k8s-app = "kube-proxy"
    }

    port {
      name        = "metrics"
      protocol    = "TCP"
      port        = "10249"
      target_port = "10249"
    }
  }
}
