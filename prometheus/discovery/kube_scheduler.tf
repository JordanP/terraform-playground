resource "kubernetes_service" "kube_scheduler" {
  metadata {
    name      = "kube-scheduler"
    namespace = "kube-system"

    annotations {
      "prometheus.io/scrape" = "true"
    }
  }

  spec {
    type       = "ClusterIP"
    cluster_ip = "None"

    selector {
      k8s-app = "kube-scheduler"
    }

    port {
      name        = "metrics"
      protocol    = "TCP"
      port        = "10251"
      target_port = "10251"
    }
  }
}
