#!/bin/bash
source ./helper.sh

[ -z "$1" ] && DATASIZE=1 || DATASIZE=$1

function drop_database() {
	local DB=$1
	local TABLES=$(show_tables "$DB")

	if [ -n "${TABLES}" ]; then
		for TABLE in ${TABLES}; do
			echo "Drop ${DB}.${TABLE}..."
			clickhouse-client -d "$DB" -q "DROP TABLE IF EXISTS ${TABLE}${POSTFIX};" > /dev/null
		done

		echo "Drop ${DB}..."
		clickhouse-client -q "DROP DATABASE IF EXISTS \`${DB}${POSTFIX}\`;" > /dev/null
	fi
}

[ -z "$1" ] && DATASIZE=1 || DATASIZE=$1
export DATABASE=${DATABASE:-${DB_PREFIX}${SUITE}${DATASIZE}}

if [ -n "$ENABLE_OPTIMIZER" ]; then
	clickhouse-client -d "$DATABASE" -q "drop stats" 2>/dev/null || true
fi

set +e
drop_database $DATABASE