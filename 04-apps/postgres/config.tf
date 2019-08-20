resource "random_id" "postgres_conf" {
  byte_length = 8
  keepers = {
    "postgresql.conf" = <<EOF
listen_addresses = '*'
max_connections = ${var.max_connections}
shared_buffers = ${var.shared_buffers}
effective_cache_size = ${var.effective_cache_size}
maintenance_work_mem = ${var.maintenance_work_mem}
checkpoint_completion_target = ${var.checkpoint_completion_target}
wal_buffers = ${var.wal_buffers}
default_statistics_target = ${var.default_statistics_target}
random_page_cost = ${var.random_page_cost}
effective_io_concurrency = ${var.effective_io_concurrency}
work_mem = ${var.work_mem}
min_wal_size = ${var.min_wal_size}
max_wal_size = ${var.max_wal_size}
max_worker_processes = ${var.max_worker_processes}
max_parallel_workers_per_gather = ${var.max_parallel_workers_per_gather}
max_parallel_workers = ${var.max_parallel_workers}
EOF
    "00configure.sh"  = <<EOF
#!/usr/bin/env bash
set -ueo pipefail

if [ -n "$${MAIN_HOSTNAME:-}" ]; then
    echo "Setting up postgres replica"
    # remove all data before doing the basebackup
    pg_ctl -D "$PGDATA" -m fast -w stop

    rm -rf "$${PGDATA:?}"/*

    until pg_isready -h "$MAIN_HOSTNAME"; do echo 'waiting for db'; sleep 1; done

    # do the initial backup from the main server
    PGPASSWORD="$REPLICA_PASSWORD" pg_basebackup -h "$MAIN_HOSTNAME" -D "$PGDATA" -U "$REPLICA_USER" -v -P -X stream

    cat <<MARKER >> "$${PGDATA}"/recovery.conf
standby_mode = on
primary_conninfo = 'host=$${MAIN_HOSTNAME} port=5432 user=$${REPLICA_USER} password=$${REPLICA_PASSWORD}'
trigger_file = '$${TRIGGER_FILE}'
MARKER
    # start postgres again
    pg_ctl -D "$${PGDATA}" -o "-c listen_addresses=''" -w start
else
    echo "Setting up postgres main"

    # create replica user
    psql postgres -U "$POSTGRES_USER" -c "CREATE USER $${REPLICA_USER} REPLICATION LOGIN CONNECTION LIMIT 5 ENCRYPTED PASSWORD '$${REPLICA_PASSWORD}'"

    # Allow replica hosts to connect
    echo "host replication $${REPLICA_USER} 0.0.0.0/0 md5" >> "$PGDATA/pg_hba.conf"
    echo "Finished setting up postgres main"
fi
EOF
  }
}

resource "kubernetes_config_map" "postgres_conf" {
  metadata {
    name      = "postgresql-config-${random_id.postgres_conf.hex}"
    namespace = (var.namespace != "default" ? kubernetes_namespace.postgresql[0].metadata.0.name : "default")
  }
  data = random_id.postgres_conf.keepers
}