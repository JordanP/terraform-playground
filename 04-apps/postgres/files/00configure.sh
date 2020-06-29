#!/usr/bin/env bash
set -ueo pipefail

if [ -n "${MAIN_HOSTNAME:-}" ]; then
    replication_slot=$(echo "${HOSTNAME:-walreceiver}" | tr - _)

    echo "Setting up postgres replica"
    pg_ctl -D "${PGDATA}" -m fast -w stop

    # remove all data before doing the basebackup
    rm -rf "${PGDATA:?}"/*

    until pg_isready -h "${MAIN_HOSTNAME}"; do echo "waiting for db $MAIN_HOSTNAME"; sleep 1; done

    # do the initial backup from the main server
    PGPASSWORD="$REPLICA_PASSWORD" pg_basebackup -h "${MAIN_HOSTNAME}" -D "${PGDATA}" -U "${REPLICA_USER}" --slot=${replication_slot} --create-slot --verbose --progress -X stream

    if [[ $PG_MAJOR == "11" ]]; then
      cat <<EOF >> "${PGDATA}"/recovery.conf
standby_mode = on
primary_conninfo = 'application_name=${replication_slot} host=${MAIN_HOSTNAME} port=5432 user=${REPLICA_USER} password=${REPLICA_PASSWORD}'
trigger_file = '${TRIGGER_FILE}'
primary_slot_name = '${replication_slot}'
EOF
    else
      touch "${PGDATA}"/postgresql.auto.conf "$PGDATA"/standby.signal
      sed --in-place -e "/primary_conninfo/d;" -e "/primary_slot_name/d;" -e \
        "$ a primary_slot_name = '${replication_slot}'" -e \
        "$ a primary_conninfo = 'application_name=${replication_slot} host=${MAIN_HOSTNAME} port=5432 user=${REPLICA_USER} password=${REPLICA_PASSWORD}'" \
        "${PGDATA}"/postgresql.auto.conf
    fi
    # start postgres again
    pg_ctl -D "$PGDATA" -o "-c listen_addresses=''" -w start
else
    echo "Setting up postgres main"

    # create replica user
    psql postgres -U "${POSTGRES_USER}" -c "CREATE USER ${REPLICA_USER} REPLICATION LOGIN CONNECTION LIMIT 6 ENCRYPTED PASSWORD '${REPLICA_PASSWORD}'"

    # Allow replica hosts to connect
    echo "host replication ${REPLICA_USER} 0.0.0.0/0 md5" >> "${PGDATA}/pg_hba.conf"

    # Note that the replication slots are created dynamically with the --create-slot option of pg_basebackup

    echo "Finished setting up postgres main"
fi