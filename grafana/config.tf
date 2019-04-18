resource "kubernetes_config_map" "grafana_config" {
  metadata {
    name      = "grafana-config"
    namespace = "monitoring"
  }

  data {
    custom.ini = "${file("${path.module}/config/custom.ini")}"
  }
}

resource "kubernetes_config_map" "grafana_dashboards_etcd" {
  metadata {
    name      = "grafana-dashboards-etcd"
    namespace = "monitoring"
  }

  data {
    etcd.json = "${file("${path.module}/config/dashboards-etcd.json")}"
  }
}

resource "kubernetes_config_map" "grafana_dashboards_k8s_resources" {
  metadata {
    name      = "grafana-dashboards-k8s-resources"
    namespace = "monitoring"
  }

  data {
    k8s-resources-cluster.json = "${file("${path.module}/config/k8s-resources-cluster.json")}"
  }
}

resource "kubernetes_config_map" "grafana_dashboards_k8s" {
  metadata {
    name      = "grafana-dashboards-k8s"
    namespace = "monitoring"
  }

  data {
    k8s-cluster-rsrc-use.json = "${file("${path.module}/config/k8s-cluster-rsrc-use.json")}"
  }
}

resource "kubernetes_config_map" "grafana_datasources" {
  metadata {
    name      = "grafana-datasources"
    namespace = "monitoring"
  }

  data {
    prometheus.yaml = "${file("${path.module}/config/prometheus.yaml")}"
    loki.yaml       = "${file("${path.module}/config/loki.yaml")}"
  }
}

resource "kubernetes_config_map" "grafana_providers" {
  metadata {
    name      = "grafana-providers"
    namespace = "monitoring"
  }

  data {
    providers.yaml = "${file("${path.module}/config/providers.yaml")}"
  }
}
