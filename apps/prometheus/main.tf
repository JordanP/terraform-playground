module "prometheus_rbac" {
  source    = "./rbac"
  namespace = var.namespace
}

module "prometheus_exporters" {
  source    = "./exporters"
  namespace = var.namespace
}

module "prometheus_discovery" {
  source = "./discovery"
}
