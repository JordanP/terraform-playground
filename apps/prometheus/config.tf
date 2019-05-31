resource "random_id" "prometheus_config_cm_name" {
  byte_length = 4

  keepers {
    data = "${filebase64sha256("${path.module}/config/config.yaml")}"
  }
}

resource "kubernetes_config_map" "prometheus_config" {
  metadata {
    name      = "prometheus-config-${random_id.prometheus_config_cm_name.hex}"
    namespace = "${var.namespace}"
  }

  data = {
    prometheus.yaml = "${file("${path.module}/config/config.yaml")}"
  }
}

resource "random_id" "prometheus_rules_cm_name" {
  byte_length = 4

  keepers {
    data1 = "${filebase64sha256("${path.module}/config/rules/etcd.yaml")}"
    data2 = "${filebase64sha256("${path.module}/config/rules/extra.yaml")}"
    data3 = "${filebase64sha256("${path.module}/config/rules/kube.yaml")}"
    data4 = "${filebase64sha256("${path.module}/config/rules/kubeprom.yaml")}"
  }
}

resource "kubernetes_config_map" "prometheus_rules" {
  metadata {
    name      = "prometheus-config-${random_id.prometheus_rules_cm_name.hex}"
    namespace = "${var.namespace}"
  }

  data = {
    etcd.yaml     = "${file("${path.module}/config/rules/etcd.yaml")}"
    extra.yaml    = "${file("${path.module}/config/rules/extra.yaml")}"
    kube.yaml     = "${file("${path.module}/config/rules/kube.yaml")}"
    kubeprom.yaml = "${file("${path.module}/config/rules/kubeprom.yaml")}"
  }
}
