resource "random_id" "config_map_suffix" {
  byte_length = 4
  keepers = {
    "enabled_plugins" = "[rabbitmq_management,rabbitmq_peer_discovery_k8s]."
    "rabbitmq.conf"   = <<EOF
log.file.level = error

## See https://www.rabbitmq.com/access-control.html#loopback-users
loopback_users.guest = true

## See https://www.rabbitmq.com/partitions.html#automatic-handling
cluster_partition_handling = pause_minority

## See https://www.rabbitmq.com/ha.html#master-migration-data-locality
queue_master_locator=min-masters

## How often should node cleanup checks run?
cluster_formation.node_cleanup.interval = 30

## Cluster formation. See https://www.rabbitmq.com/cluster-formation.html to learn more.
cluster_formation.peer_discovery_backend = rabbit_peer_discovery_k8s
cluster_formation.k8s.host = kubernetes.default.svc.cluster.local
cluster_formation.k8s.address_type = hostname

## Set to false if automatic removal of unknown/absent nodes
## is desired. This can be dangerous, see
##  * https://www.rabbitmq.com/cluster-formation.html#node-health-checks-and-cleanup
##  * https://groups.google.com/forum/#!msg/rabbitmq-users/wuOfzEywHXo/k8z_HWIkBgAJ
cluster_formation.node_cleanup.only_log_warning = true
EOF
  }
}

resource "kubernetes_config_map" "rabbitmq" {
  metadata {
    name      = "rabbitmq-${random_id.config_map_suffix.hex}"
    namespace = (var.namespace != "default" ? kubernetes_namespace.rabbitmq[0].metadata.0.name : "default")
  }
  data = random_id.config_map_suffix.keepers
}

resource "random_string" "erlang_cookie" {
  length  = 48
  special = false
}

resource "kubernetes_secret" "rabbitmq" {
  metadata {
    name      = "rabbitmq"
    namespace = (var.namespace != "default" ? kubernetes_namespace.rabbitmq[0].metadata.0.name : "default")
  }

  data = {
    erlang-cookie = random_string.erlang_cookie.result
  }
}