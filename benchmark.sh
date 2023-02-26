#!/bin/bash
source ./config.sh
source ./helper.sh

[ -z "$1" ] && DATASIZE=1 || DATASIZE=$1
DATABASE=${DATABASE:-${DB_PREFIX}${SUITE}${DATASIZE}${DB_SUFFIX}}

TIMEOUT=${TIMEOUT:-600}
RESULT=${RESULT:-${LOGDIR}/result.csv}
SQL_DIR=${SCRIPTPATH}/sql
LOG_CUR=${LOGDIR}/curr.txt

echo "qid,duration,status" > "$RESULT"

if [ "$ENABLE_OPTIMIZER" == "true" ]; then
	clickhouse_client "create stats if not exists all" -d "$DATABASE"
	clickhouse_client "show stats all format PrettyCompact" -d "$DATABASE" >> $TRACE_LOG
fi

set -e

log "Run warm up sql..."
if [ -f ${SQL_DIR}/warmup.sql ]; then
    QUERY=$(cat "${SQL_DIR}/warmup.sql")
    log "$QUERY"
	clickhouse_client "$QUERY" -d "$DATABASE" > /dev/null
fi

function benchmark_query() {
    for i in {1..18}; do

        SQL=$(sed -e "/^--/d; s/${SUITE}\./${DATABASE}\./g" ${1})
        if [ "${ENABLE_ENGINE_TIME}" == "true" ]; then 
            DURATION=$(clickhouse_client "$SQL" -d $DATABASE -t --format=Null 2>&1) && RET=0 || RET=$?
            DURATION=$(sec_to_ms ${DURATION})
        else
            CMD=$(clickhouse_client_cmd "$SQL" "-d $DATABASE -t --format=Null")
            /usr/bin/time -p -o time.txt timeout $TIMEOUT sh -c "$CMD" > $LOG_CUR 2>&1 && RET=0 || RET=$?
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

	[[ -f time.txt ]] && DURATION=$(parse_time)

	# workaround for case that engine error happens but returns 0
	if [ $RET -eq 0 ]; then
		VAL=$(sed -n "s|^Code: \([0-9]\+\), e.displayText().*$|\1|p" $LOG_CUR)
		if [ -n "$VAL" ]; then
			RET=$VAL
		fi
	fi
	
	case $RET in
		32)
			echo "crashed (Code: ${RET}), sleep 300 seconds..." && sleep 300 && STATUS=${RET}
			;; 
		49)
			echo "crashed (Code: ${RET}), sleep 300 seconds..." && sleep 300 && STATUS=${RET}
			;; 
		174)
			echo "crashed (Code: ${RET}), sleep 100 seconds..." && sleep 100 && STATUS=${RET}
			;; 
		279)
			echo "crashed (Code: ${RET}), sleep 100 seconds..." && sleep 100 && STATUS=${RET}
			;;
		241)
			echo "MEMORY_LIMIT_EXCEEDED, sleep 200 seconds..." && sleep 200 && STATUS=${RET}
			;;
		124)
			TIMEOUT_MS=$((TIMEOUT*1000))
			if [ "$DURATION" -lt "$TIMEOUT_MS" ]; then
				RET=1124
			fi

			STATUS="Timeout"
			;;
		$TIMEOUT_VAL)
			STATUS="Engine crash"
			;;
		*)
			STATUS=$RET
			;;
	esac
}


TIMEOUT_VAL=999999

QPATH="$SQL_DIR/${QPATH_SUFFIX}"

TOTAL_DURATION=0

for FILE_PATH in ${QPATH}/*.sql; do
	QID=$(query_file_to_id ${FILE_PATH})
	benchmark_query ${FILE_PATH}
    log "[Query$QID]duration: ${DURATION}ms, status: ${STATUS}"
	echo "${QUERY},${DURATION},${STATUS}" >> $RESULT
    TOTAL_DURATION=$(($TOTAL_DURATION + $DURATION))
done

log "total duration: ${TOTAL_DURATION}ms"


