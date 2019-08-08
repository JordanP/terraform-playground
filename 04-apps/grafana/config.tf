resource "random_id" "grafana_dashboards_k8s_cm_name" {
  byte_length = 4

  keepers = {
    data1 = filebase64sha256("${path.module}/config/dashboards-etcd.json")
    data2 = filebase64sha256("${path.module}/config/k8s-resources-cluster.json")
    data3 = filebase64sha256("${path.module}/config/k8s-cluster-rsrc-use.json")
  }
}

resource "kubernetes_config_map" "grafana_dashboards_k8s" {
  metadata {
    name      = "grafana-dashboards-k8s-${random_id.grafana_dashboards_k8s_cm_name.hex}"
    namespace = var.namespace
  }

  data = {
    "etcd.json"                  = file("${path.module}/config/dashboards-etcd.json")
    "k8s-resources-cluster.json" = file("${path.module}/config/k8s-resources-cluster.json")
    "k8s-cluster-rsrc-use.json"  = file("${path.module}/config/k8s-cluster-rsrc-use.json")
  }
}

resource "random_id" "grafana_dashboards_nodes_cm_name" {
  byte_length = 4

  keepers = {
    data1 = filebase64sha256("${path.module}/config/node-exporter-full.json")
  }
}

resource "kubernetes_config_map" "grafana_dashboards_nodes" {
  metadata {
    name      = "grafana-dashboards-nodes-${random_id.grafana_dashboards_nodes_cm_name.hex}"
    namespace = var.namespace
  }

  data = {
    "node-exporter-full.json" = file("${path.module}/config/node-exporter-full.json")
  }
}

resource "random_id" "grafana_config_cm_name" {
  byte_length = 4

  keepers = {
    data = filebase64sha256("${path.module}/config/custom.ini")
  }
}

resource "kubernetes_config_map" "grafana_config" {
  metadata {
    name      = "grafana-config-${random_id.grafana_config_cm_name.hex}"
    namespace = var.namespace
  }

  data = {
    "custom.ini" = file("${path.module}/config/custom.ini")
  }
}

resource "random_id" "grafana_datasources_cm_name" {
  byte_length = 4

  keepers = {
    data1 = filebase64sha256("${path.module}/config/prometheus.yaml")
    data2 = filebase64sha256("${path.module}/config/loki.yaml")
  }
}

resource "kubernetes_config_map" "grafana_datasources" {
  metadata {
    name      = "grafana-datasources-${random_id.grafana_dashboards_k8s_cm_name.hex}"
    namespace = var.namespace
  }

  data = {
    "prometheus.yaml" = file("${path.module}/config/prometheus.yaml")
    "loki.yaml"       = file("${path.module}/config/loki.yaml")
  }
}

resource "random_id" "grafana_providers_cm_name" {
  byte_length = 4

  keepers = {
    data = filebase64sha256("${path.module}/config/providers.yaml")
  }
}

resource "kubernetes_config_map" "grafana_providers" {
  metadata {
    name      = "grafana-providers-${random_id.grafana_providers_cm_name.hex}"
    namespace = var.namespace
  }

  data = {
    "providers.yaml" = file("${path.module}/config/providers.yaml")
  }
}

resource "random_id" "grafana_initial_admin_password" {
  byte_length = 8
}

resource "kubernetes_secret" "grafana_initial_admin_password" {
  metadata {
    name      = "grafana-initial-admin-password"
    namespace = var.namespace
  }

  data = {
    grafana-admin-password = random_id.grafana_initial_admin_password.hex
  }
}
