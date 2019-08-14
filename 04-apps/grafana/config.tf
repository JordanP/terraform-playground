resource "random_id" "grafana_dashboards_k8s_cm_name" {
  byte_length = 4

  keepers = {
    data1 = filebase64sha256("${path.module}/config/dashboards/dashboards-k8s/apiserver.json")
    data2 = filebase64sha256("${path.module}/config/dashboards/dashboards-k8s/controller-manager.json")
    data3 = filebase64sha256("${path.module}/config/dashboards/dashboards-k8s/persistentvolumesusage.json")
    data4 = filebase64sha256("${path.module}/config/dashboards/dashboards-k8s/pods.json")
    data5 = filebase64sha256("${path.module}/config/dashboards/dashboards-k8s/scheduler.json")
    data6 = filebase64sha256("${path.module}/config/dashboards/dashboards-k8s/statefulset.json")
  }
}

resource "kubernetes_config_map" "grafana_dashboards_k8s" {
  metadata {
    name      = "grafana-dashboards-k8s-${random_id.grafana_dashboards_k8s_cm_name.hex}"
    namespace = var.namespace
  }

  data = {
    "apiserver.json"              = file("${path.module}/config/dashboards/dashboards-k8s/apiserver.json")
    "controller-manager.json"     = file("${path.module}/config/dashboards/dashboards-k8s/controller-manager.json")
    "persistentvolumesusage.json" = file("${path.module}/config/dashboards/dashboards-k8s/persistentvolumesusage.json")
    "pods.json"                   = file("${path.module}/config/dashboards/dashboards-k8s/pods.json")
    "scheduler.json"              = file("${path.module}/config/dashboards/dashboards-k8s/scheduler.json")
    "statefulset.json"            = file("${path.module}/config/dashboards/dashboards-k8s/statefulset.json")
  }
}

resource "random_id" "grafana_dashboards_k8s_nodes_cm_name" {
  byte_length = 4

  keepers = {
    data1 = filebase64sha256("${path.module}/config/dashboards/dashboards-k8s-nodes/kubelet.json")
    data2 = filebase64sha256("${path.module}/config/dashboards/dashboards-k8s-nodes/nodes.json")
    data3 = filebase64sha256("${path.module}/config/dashboards/dashboards-k8s-nodes/proxy.json")
  }
}

resource "kubernetes_config_map" "grafana_dashboards_k8s_nodes" {
  metadata {
    name      = "grafana-dashboards-k8s-nodes-${random_id.grafana_dashboards_k8s_nodes_cm_name.hex}"
    namespace = var.namespace
  }

  data = {
    "kubelet.json" = file("${path.module}/config/dashboards/dashboards-k8s-nodes/kubelet.json")
    "nodes.json"   = file("${path.module}/config/dashboards/dashboards-k8s-nodes/nodes.json")
    "proxy.json"   = file("${path.module}/config/dashboards/dashboards-k8s-nodes/proxy.json")
  }
}

resource "random_id" "grafana_dashboards_k8s_resources_cm_name" {
  byte_length = 4

  keepers = {
    data1 = filebase64sha256("${path.module}/config/dashboards/dashboards-k8s-resources/k8s-cluster-rsrc-use.json")
    data2 = filebase64sha256("${path.module}/config/dashboards/dashboards-k8s-resources/k8s-node-rsrc-use.json")
    data3 = filebase64sha256("${path.module}/config/dashboards/dashboards-k8s-resources/k8s-resources-cluster.json")
    data4 = filebase64sha256("${path.module}/config/dashboards/dashboards-k8s-resources/k8s-resources-namespace.json")
    data5 = filebase64sha256("${path.module}/config/dashboards/dashboards-k8s-resources/k8s-resources-pod.json")
    data6 = filebase64sha256("${path.module}/config/dashboards/dashboards-k8s-resources/k8s-resources-workload.json")
    data7 = filebase64sha256("${path.module}/config/dashboards/dashboards-k8s-resources/k8s-resources-workloads-namespace.json")
  }
}

resource "kubernetes_config_map" "grafana_dashboards_k8s_resources" {
  metadata {
    name      = "grafana-dashboards-k8s-resources-${random_id.grafana_dashboards_k8s_resources_cm_name.hex}"
    namespace = var.namespace
  }

  data = {
    "k8s-cluster-rsrc-use.json"              = file("${path.module}/config/dashboards/dashboards-k8s-resources/k8s-cluster-rsrc-use.json")
    "k8s-node-rsrc-use.json"                 = file("${path.module}/config/dashboards/dashboards-k8s-resources/k8s-node-rsrc-use.json")
    "k8s-resources-cluster.json"             = file("${path.module}/config/dashboards/dashboards-k8s-resources/k8s-resources-cluster.json")
    "k8s-resources-namespace.json"           = file("${path.module}/config/dashboards/dashboards-k8s-resources/k8s-resources-namespace.json")
    "k8s-resources-pod.json"                 = file("${path.module}/config/dashboards/dashboards-k8s-resources/k8s-resources-pod.json")
    "k8s-resources-workload.json"            = file("${path.module}/config/dashboards/dashboards-k8s-resources/k8s-resources-workload.json")
    "k8s-resources-workloads-namespace.json" = file("${path.module}/config/dashboards/dashboards-k8s-resources/k8s-resources-workloads-namespace.json")
  }
}

resource "random_id" "grafana_dashboards_prom_cm_name" {
  byte_length = 4

  keepers = {
    data1 = filebase64sha256("${path.module}/config/dashboards/dashboards-prom/prometheus.json")
    data2 = filebase64sha256("${path.module}/config/dashboards/dashboards-prom/prometheus-remote-write.json")
  }
}

resource "kubernetes_config_map" "grafana_dashboards_prom" {
  metadata {
    name      = "grafana-dashboards-prom-${random_id.grafana_dashboards_prom_cm_name.hex}"
    namespace = var.namespace
  }

  data = {
    "prometheus.json"              = file("${path.module}/config/dashboards/dashboards-prom/prometheus.json")
    "prometheus-remote-write.json" = file("${path.module}/config/dashboards/dashboards-prom/prometheus-remote-write.json")
  }
}

resource "random_id" "grafana_dashboards_etcd_cm_name" {
  byte_length = 4

  keepers = {
    data1 = filebase64sha256("${path.module}/config/dashboards/dashboards-etcd/etcd.json")
  }
}

resource "kubernetes_config_map" "grafana_dashboards_etcd" {
  metadata {
    name      = "grafana-dashboards-etcd-${random_id.grafana_dashboards_etcd_cm_name.hex}"
    namespace = var.namespace
  }

  data = {
    "etcd.json" = file("${path.module}/config/dashboards/dashboards-etcd/etcd.json")
  }
}


resource "random_id" "grafana_dashboards_nodes_cm_name" {
  byte_length = 4

  keepers = {
    data1 = filebase64sha256("${path.module}/config/dashboards/node-exporter-full.json")
  }
}

resource "kubernetes_config_map" "grafana_dashboards_nodes" {
  metadata {
    name      = "grafana-dashboards-nodes-${random_id.grafana_dashboards_nodes_cm_name.hex}"
    namespace = var.namespace
  }

  data = {
    "node-exporter-full.json" = file("${path.module}/config/dashboards/node-exporter-full.json")
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
    data1 = filebase64sha256("${path.module}/config/datasources.yaml")
  }
}

resource "kubernetes_config_map" "grafana_datasources" {
  metadata {
    name      = "grafana-datasources-${random_id.grafana_dashboards_k8s_cm_name.hex}"
    namespace = var.namespace
  }

  data = {
    "datasources.yaml" = file("${path.module}/config/datasources.yaml")
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
