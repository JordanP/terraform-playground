resource "random_id" "pgbouncer_datadog_password" {
  byte_length = 12
}

resource "random_id" "pgbouncer_config" {
  byte_length = 4
  keepers = {
    # PGBouncer admin console is available through the Unix socket:
    # psql -h /tmp -U pgbouncer
    # https://www.pgbouncer.org/usage.html#admin-console
    "pgbouncer.ini" = <<EOF
[databases]
*=host=${var.pg_primary_hostname} port=5432
[pgbouncer]
user=postgres
listen_addr = *
listen_port = 5432
auth_type = md5
auth_file = /etc/pgbouncer/auth.txt
pool_mode = transaction
default_pool_size = ${var.default_pool_size}
max_client_conn = ${var.max_client_conn}
;; Close connections which are in "IDLE in transaction" state longer than this many *seconds*.
idle_transaction_timeout = 60
ignore_startup_parameters=options,extra_float_digits
stats_users = datadog
    EOF
    # PG's md5 is md5(password+User)
    "auth.txt" = <<EOF
"postgres" "md5${md5("${var.pg_primary_postgres_password}postgres")}"
"datadog" "md5${md5("${random_id.pgbouncer_datadog_password.hex}datadog")}"
  EOF
  }
}

resource "kubernetes_config_map" "pgbouncer_config" {
  metadata {
    name      = "pgbouncer-conf-${random_id.pgbouncer_config.hex}"
    namespace = var.namespace
  }
  data = random_id.pgbouncer_config.keepers
}
