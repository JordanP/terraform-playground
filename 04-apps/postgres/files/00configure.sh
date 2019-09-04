#!/usr/bin/env bash
set -ueo pipefail

if [ -n "${MAIN_HOSTNAME:-}" ]; then
    echo "Setting up postgres replica"
    # remove all data before doing the basebackup
    pg_ctl -D "$PGDATA" -m fast -w stop

    rm -rf "${PGDATA:?}"/*

    until pg_isready -h "$MAIN_HOSTNAME"; do echo 'waiting for db'; sleep 1; done

    # do the initial backup from the main server
    PGPASSWORD="$REPLICA_PASSWORD" pg_basebackup -h "$MAIN_HOSTNAME" -D "$PGDATA" -U "$REPLICA_USER" -v -P -X stream

    cat <<MARKER >> "${PGDATA}"/recovery.conf
standby_mode = on
primary_conninfo = 'host=${MAIN_HOSTNAME} port=5432 user=${REPLICA_USER} password=${REPLICA_PASSWORD}'
trigger_file = '${TRIGGER_FILE}'
MARKER
    # start postgres again
    pg_ctl -D "${PGDATA}" -o "-c listen_addresses=''" -w start
else
    echo "Setting up postgres main"

    # create replica user
    psql postgres -U "$POSTGRES_USER" -c "CREATE USER ${REPLICA_USER} REPLICATION LOGIN CONNECTION LIMIT 5 ENCRYPTED PASSWORD '${REPLICA_PASSWORD}'"

    # Allow replica hosts to connect
    echo "host replication ${REPLICA_USER} 0.0.0.0/0 md5" >> "$PGDATA/pg_hba.conf"
    echo "Finished setting up postgres main"
fi