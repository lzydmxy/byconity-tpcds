#!/bin/bash
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

set -e
source ./config.sh
source ./helper.sh

SIZE=$1

if [ -z "$PARALLEL" ]; then
    PARALLEL=$(($(grep -c ^processor /proc/cpuinfo)/2))
    if (( PARALLEL < 2 )); then
        PARALLEL=2
    fi
fi

log "set PARALLEL ${PARALLEL}"

usage() {
	echo "usage: $0 <size(gb)> <flag>"
	echo "  if you want to replace empty cell, use $0 <size> 1"
}

gen_data() {
	local CSVPATH=${SCRIPTPATH}/data_tpcds_${SIZE}
	[ ! -d $CSVPATH ] && mkdir $CSVPATH || true

	local PARALLEL=${PARALLEL:-1}
	log "Generating ${DATASIZE}G TPCDS data in ${CSVPATH}, with PARALLEL ${PARALLEL}, RNGSEED ${SEED}..."
	if [ "$PARALLEL" == 1 ]; then
		$TOOLS_PATH/dsdgen -SCALE $DATASIZE -DELIMITER \| -CHILD __ -TERMINATE N \
			-RNGSEED $SEED -DISTRIBUTIONS $TOOLS_PATH/tpcds.idx -DIR $CSVPATH 2>&1 | tee -a $OUTPUT_LOG
	else
		seq 1 $PARALLEL | xargs -t -P$PARALLEL -I__ \
		$TOOLS_PATH/dsdgen -SCALE $DATASIZE -DELIMITER \| -PARALLEL $PARALLEL -CHILD __ -TERMINATE N \
			-RNGSEED $SEED -DISTRIBUTIONS $TOOLS_PATH/tpcds.idx -DIR $CSVPATH 2>&1 | tee -a $OUTPUT_LOG
	fi
}

[ -z $SIZE ] && usage && exit 1

[ -z "$1" ] && DATASIZE=1 || DATASIZE=$1
if [ $DATASIZE -eq 1 ]; then
	SEED=42
else
	SEED=19620718
fi

gen_data

log "Splitting generated data..."
mv data_tpcds_${SIZE} data_tpcds_${SIZE}_orig && cd data_tpcds_${SIZE}_orig && ../split.sh ../data_tpcds_${SIZE} | tee -a $OUTPUT_LOG && cd .. && rm -r data_tpcds_${SIZE}_orig