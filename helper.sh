SCRIPTPATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
LOGDIR=${LOGDIR:-${SCRIPTPATH}/logs}
OUTPUT_LOG=${LOGDIR}/output.log
ERROR_LOG=${LOGDIR}/error.log
TOOLS_PATH=${SCRIPTPATH}/build/tools
SUITE=${SUITE:-tpcds}
CLUSTER_NAME=${CLUSTER_NAME:-cluster}
CLIENT_TYPE="CH"
if [ -n "$BUCKET_SIZE" ]; then
	DB_PREFIX=${DB_PREFIX}bucket${BUCKET_SIZE}
fi

if [ -n "$SRV_USER" ]; then
    if [ -n "$SRV_PASSWORD" ]; then
        USER_OPTS="--user ${SRV_USER} --password ${SRV_PASSWORD}"
    else
        USER_OPTS="--user ${SRV_USER} --password \"\""
    fi
fi

if [ -n "$ENABLE_OPTIMIZER" ]; then
    OPTIMIZER_OPTS=" --enable_optimizer=1 --dialect_type='ANSI'"
    OPTIMIZER_SETS="set enable_optimizer=1; set dialect_type='ANSI'; "
    QPATH_SUFFIX=ansi
fi

if [ ! -d $LOGDIR ]; then
    mkdir -p $LOGDIR
fi

# call clickhouse client to execute sql, $1 has the sql, addtional parameters will be added to the clickhouse client
function clickhouse_client_cmd() {
    if [ $CLIENT_TYPE == "CH" ]; then
        QUERY=$(sed 's|\"|\\\"|g' <<<"${OPTIMIZER_SETS} $1")
        echo "$SCRIPTPATH/bin/clickhouse client $CLIENT_ARGS --distributed_product_mode=allow --send_timeout=2147483647 --receive_timeout=2147483647 $USER_OPTS --port=$SRV_TCP_PORT --host=$SRV_IP -mn -q \"$QUERY\" ${@:2}"
    else
        QUERY=$(sed 's|\"|\\\"|g' <<<"$1")
        echo "$SCRIPTPATH/bin/clickhouse client $CLIENT_ARGS $OPTIMIZER_OPTS --distributed_product_mode=allow --send_timeout=2147483647 --receive_timeout=2147483647 $USER_OPTS --port=$SRV_TCP_PORT --host=$SRV_IP -mn -q \"$QUERY\" ${@:2}"
    fi
}

function clickhouse_client() {
    CMD=$(clickhouse_client_cmd "$1" "${@:2}")
    sh -c "$CMD" 2>$ERROR_LOG
}

# $1 is the database name
function show_tables() {
	clickhouse_client "show tables" -d "$1"
}

function log() {
    echo "[$(date +"%x %T.%3N")] $1" | tee -a $OUTPUT_LOG
}
