# 
#  Copyright (2022) Bytedance Ltd. and/or its affiliates
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#  
#      http://www.apache.org/licenses/LICENSE-2.0
#  
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
# 

SCRIPTPATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
LOGDIR=${LOGDIR:-${SCRIPTPATH}/logs}
OUTPUT_LOG=${LOGDIR}/output.log
TRACE_LOG=${LOGDIR}/trace.log
TOOLS_PATH=${SCRIPTPATH}/build/tools
SUITE=${SUITE:-tpcds}
CLUSTER_NAME=${CLUSTER_NAME:-cluster}
CLIENT_TYPE="ByConity"
ENABLE_TRACE="true"

if [ -n "$SRV_USER" ]; then
    if [ -n "$SRV_PASSWORD" ]; then
        USER_OPTS="--user ${SRV_USER} --password ${SRV_PASSWORD}"
    else
        USER_OPTS="--user ${SRV_USER} --password \"\""
    fi
fi

OPTIMIZER_OPTS=" --enable_optimizer=1 --dialect_type='ANSI'"
OPTIMIZER_SETS="set enable_optimizer=1; set dialect_type='ANSI'; "

if [ ! -d $LOGDIR ]; then
    mkdir -p $LOGDIR
fi

function log() {
    echo "[$(date +"%x %T.%3N")] $1" | tee -a $OUTPUT_LOG
}

function trace() {
    echo "[$(date +"%x %T.%3N")] $1" >> $TRACE_LOG
}

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
    if [ -n "$ENABLE_TRACE" ]; then
        trace "$CMD"
    fi
    sh -c "$CMD"
}

# $1 is the database name
function show_tables() {
	clickhouse_client "show tables" -d "$1"
}

function query_file_to_id() {
	echo $(basename -s .sql $1) | sed 's/^0\?//g'
}

function sec_to_ms() {
	local DURATION=$(bc <<< $1*1000)
	echo ${DURATION%.*}
}
