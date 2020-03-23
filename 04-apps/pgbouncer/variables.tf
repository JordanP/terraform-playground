variable "namespace" {
  description = "Kubernetes namespace for PGBouncer"
  default     = "postgres"
}
variable "pg_primary_hostname" {
  description = "In the form $servicename.$namespace"
}
variable "pg_primary_postgres_password" {}
variable "resources_requests" {
  type = object({
    cpu    = string
    memory = string
  })
  default = {
    cpu    = "10m"
    memory = "256Mi"
  }
}

variable "max_client_conn" {
  description = "Maximum number of *client* connections allowed. "
}
variable "default_pool_size" {
  description = "How many *server* connections to allow per user/database pair."
  default     = 20
}
variable "replicas" {
  default = 1
}
variable "node_selector" {
  type = map(string)
  default = {
    node_type = "standard"
  }
}
