resource "kubernetes_service" "kube_controller_manager" {
  metadata {
    name      = "kube-controller-manager"
    namespace = "kube-system"

    annotations {
      "prometheus.io/scrape" = "true"
    }
  }

  spec {
    type       = "ClusterIP"
    cluster_ip = "None"

    selector {
      k8s-app = "kube-controller-manager"
    }

    port {
      name        = "metrics"
      protocol    = "TCP"
      port        = "10252"
      target_port = "10252"
    }
  }
}
