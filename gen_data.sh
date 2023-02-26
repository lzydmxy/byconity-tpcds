#!/bin/bash
set -e
source ./helper.sh

SIZE=$1
REPLACE_FLAG=$2

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

	[ $SIZE -eq 1 ] && cp tpcds1_fix/web_page.dat $CSVPATH || true
	if [ "$REPLACE_FLAG"x == "1"x ]; then
		for f in $(ls $CSVPATH); do
			log "Replacing  empty cell in $CSVPATH/$f"
			sed -i "s#||#|\\\N|#g;s#||#|\\\N|#g" $CSVPATH/$f
		done
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