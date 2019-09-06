variable helm_release_name {}

variable postgresql_host {}
variable postgresql_username {}
variable postgresql_password {}
variable postgresql_database {}

variable force_destroy_buckets {
  default = true
}

variable redis_password {}

variable "tls_certificate" {}
variable "tls_private_key" {}

