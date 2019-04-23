resource "random_id" "grafana_config_cm_name" {
  byte_length = 4

  keepers {
    data = "${filebase64sha256("${path.module}/config/custom.ini")}"
  }
}

resource "kubernetes_config_map" "grafana_config" {
  metadata {
    name      = "grafana-config-${random_id.grafana_config_cm_name.hex}"
    namespace = "${kubernetes_namespace.monitoring.metadata.0.name}"
  }

  data {
    custom.ini = "${file("${path.module}/config/custom.ini")}"
  }
}

resource "random_id" "grafana_dashboards_etcd_cm_name" {
  byte_length = 4

  keepers {
    data = "${filebase64sha256("${path.module}/config/dashboards-etcd.json")}"
  }
}

resource "kubernetes_config_map" "grafana_dashboards_etcd" {
  metadata {
    name      = "grafana-dashboards-etcd-${random_id.grafana_dashboards_etcd_cm_name.hex}"
    namespace = "${kubernetes_namespace.monitoring.metadata.0.name}"
  }

  data {
    etcd.json = "${file("${path.module}/config/dashboards-etcd.json")}"
  }
}

resource "random_id" "grafana_dashboards_k8s_resources_cm_name" {
  byte_length = 4

  keepers {
    data = "${filebase64sha256("${path.module}/config/k8s-resources-cluster.json")}"
  }
}

resource "kubernetes_config_map" "grafana_dashboards_k8s_resources" {
  metadata {
    name      = "grafana-dashboards-k8s-resources-${random_id.grafana_dashboards_k8s_resources_cm_name.hex}"
    namespace = "${kubernetes_namespace.monitoring.metadata.0.name}"
  }

  data {
    k8s-resources-cluster.json = "${file("${path.module}/config/k8s-resources-cluster.json")}"
  }
}

resource "random_id" "grafana_dashboards_k8s_cm_name" {
  byte_length = 4

  keepers {
    data = "${filebase64sha256("${path.module}/config/k8s-cluster-rsrc-use.json")}"
  }
}

resource "kubernetes_config_map" "grafana_dashboards_k8s" {
  metadata {
    name      = "grafana-dashboards-k8s-${random_id.grafana_dashboards_k8s_cm_name.hex}"
    namespace = "${kubernetes_namespace.monitoring.metadata.0.name}"
  }

  data {
    k8s-cluster-rsrc-use.json = "${file("${path.module}/config/k8s-cluster-rsrc-use.json")}"
  }
}

resource "random_id" "grafana_datasources_cm_name" {
  byte_length = 4

  keepers {
    data1 = "${filebase64sha256("${path.module}/config/prometheus.yaml")}"
    data2 = "${filebase64sha256("${path.module}/config/loki.yaml")}"
  }
}

resource "kubernetes_config_map" "grafana_datasources" {
  metadata {
    name      = "grafana-datasources-${random_id.grafana_dashboards_k8s_cm_name.hex}"
    namespace = "${kubernetes_namespace.monitoring.metadata.0.name}"
  }

  data {
    prometheus.yaml = "${file("${path.module}/config/prometheus.yaml")}"
    loki.yaml       = "${file("${path.module}/config/loki.yaml")}"
  }
}

resource "random_id" "grafana_providers_cm_name" {
  byte_length = 4

  keepers {
    data = "${filebase64sha256("${path.module}/config/providers.yaml")}"
  }
}

resource "kubernetes_config_map" "grafana_providers" {
  metadata {
    name      = "grafana-providers-${random_id.grafana_providers_cm_name.hex}"
    namespace = "${kubernetes_namespace.monitoring.metadata.0.name}"
  }

  data {
    providers.yaml = "${file("${path.module}/config/providers.yaml")}"
  }
}

resource "random_id" "grafana_admin_password" {
  byte_length = 8
}

resource "kubernetes_secret" "grafana_secret" {
  metadata {
    generate_name = "grafana-secret"
    namespace     = "${kubernetes_namespace.monitoring.metadata.0.name}"
  }

  data {
    grafana-admin-password = "${random_id.grafana_admin_password.hex}"
  }
}
