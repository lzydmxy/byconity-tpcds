#!/bin/bash
source ./config.sh
source ./helper.sh

[ -z "$1" ] && DATASIZE=1 || DATASIZE=$1
DATABASE=${DATABASE:-${DB_PREFIX}${SUITE}${DATASIZE}${DB_SUFFIX}}

TIMEOUT=${TIMEOUT:-600}
RESULT=${RESULT:-${LOGDIR}/result.csv}
SQL_DIR=${SCRIPTPATH}/sql
LOG_CUR=$LOGDIR/curr.txt
TIME_FILE=$LOGDIR/time.txt

echo "qid,duration,status" > "$RESULT"

clickhouse_client "create stats if not exists all" -d "$DATABASE"
clickhouse_client "show stats all format PrettyCompact" -d "$DATABASE" >> $TRACE_LOG

set -e

log "Run warm up sql..."
if [ -f ${SQL_DIR}/warmup.sql ]; then
    QUERY=$(cat "${SQL_DIR}/warmup.sql")
    log "$QUERY"
	clickhouse_client "$QUERY" -d "$DATABASE" > /dev/null
fi

function parse_time() {
	sec_to_ms $(cat ${TIME_FILE} | grep real | awk '{print $2}'; rm ${TIME_FILE} > /dev/null)
}

function benchmark_query() {
    for i in {1..18}; do
        SQL=$(sed -e "/^--/d; s/${SUITE}\./${DATABASE}\./g" ${1})
        if [ "${ENABLE_ENGINE_TIME}" == "true" ]; then 
            DURATION=$(clickhouse_client "$SQL" -d $DATABASE -t --format=Null 2>&1) && RET=0 || RET=$?
            DURATION=$(sec_to_ms ${DURATION})
        else
            CMD=$(clickhouse_client_cmd "$SQL" "-d $DATABASE -t --format=Null")
            /usr/bin/time -p -o "${TIME_FILE}" timeout $TIMEOUT sh -c "$CMD" >${LOG_CUR} 2>&1 && RET=0 || RET=$?
        fi 

        # connection refused, try again
        if [ $RET -ne 210 ]; then
            break
        fi
        sleep 5
    done
    if [ $RET -eq 210 ]; then
        echo "server down, abort testing"
        exit 1
    fi

	[[ -f "${TIME_FILE}" ]] && DURATION=$(parse_time)

	# workaround for case that engine error happens but returns 0
	if [ $RET -eq 0 ]; then
		VAL=$(sed -n "s|^Code: \([0-9]\+\), e.displayText().*$|\1|p" $LOG_CUR)
		if [ -n "$VAL" ]; then
			RET=$VAL
		fi
	fi
	
	STATUS=$RET
}


TIMEOUT_VAL=999999

QPATH="$SQL_DIR"

TOTAL_DURATION=0

log "Run benchmark sql from ${QPATH}"
for FILE_PATH in ${QPATH}/*.sql; do
	QID=$(query_file_to_id ${FILE_PATH})
	benchmark_query ${FILE_PATH}
    log "[Query$QID]duration: ${DURATION}ms, status: ${STATUS}"
	echo "${QID},${DURATION},${STATUS}" >> $RESULT
    TOTAL_DURATION=$(($TOTAL_DURATION + $DURATION))
done

log "total duration: ${TOTAL_DURATION}ms"


