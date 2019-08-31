resource "kubernetes_service" "postgres_rw" {
  metadata {
    labels = {
      app = "postgresql"
    }

    name      = "postgres-rw"
    namespace = (var.namespace != "default" ? kubernetes_namespace.postgresql[0].metadata.0.name : "default")
  }

  spec {
    port {
      name        = "postgres"
      target_port = "postgresql"
      port        = "5432"
      protocol    = "TCP"
    }

    selector = {
      app  = "postgresql"
      role = "master"
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_service" "postgres_ro" {
  metadata {
    labels = {
      app = "postgresql"
    }

    name      = "postgres-ro"
    namespace = (var.namespace != "default" ? kubernetes_namespace.postgresql[0].metadata.0.name : "default")
  }

  spec {
    port {
      name        = "postgres"
      target_port = "postgresql"
      port        = "5432"
      protocol    = "TCP"
    }

    selector = {
      app  = "postgresql"
      role = "replica"
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_service" "postgres_headless" {
  metadata {
    labels = {
      app = "postgresql"
    }

    name      = "postgres-headless"
    namespace = (var.namespace != "default" ? kubernetes_namespace.postgresql[0].metadata.0.name : "default")
  }

  spec {
    port {
      name        = "postgres"
      target_port = "postgresql"
      port        = "5432"
      protocol    = "TCP"
    }

    selector = {
      app = "postgresql"
    }

    type       = "ClusterIP"
    cluster_ip = "None"
  }
}