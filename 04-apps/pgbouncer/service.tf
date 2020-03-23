resource "kubernetes_service" "pgbouncer" {
  metadata {
    name      = "pg-bouncer"
    namespace = var.namespace
    labels = {
      app = "pg-bouncer"
    }
    annotations = {
      "ad.datadoghq.com/endpoints.check_names"  = "[\"pgbouncer\"]"
      "ad.datadoghq.com/endpoints.init_configs" = "[{}]"
      "ad.datadoghq.com/endpoints.instances"    = "[{\"database_url\": \"postgresql://datadog:${random_id.pgbouncer_datadog_password.hex}@%%host%%/pgbouncer\"}]"
    }
  }
  spec {
    port {
      port = 5432
      name = "pgbouncer"
    }
    type = "ClusterIP"
    # Headless service: no kube-proxy (no load balancing or proxying done)
    cluster_ip = "None"
    # For headless Services that define selectors, the endpoints controller creates
    # Endpoints records in the API, and modifies the DNS configuration to return records
    # (addresses) that point directly to the Pods backing the Service
    selector = {
      app = "pg-bouncer"
    }
  }
}
