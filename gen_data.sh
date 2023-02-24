#!/bin/bash
set -e
source ./helper.sh

SIZE=$1
REPLACE_FLAG=$2

usage() {
	echo "usage: $0 <size(gb)> <flag>"
	echo "  if you want to replace empty cell, use $0 <size> 1"
}

build_tools() {
    local SOURCE_PATH=${SCRIPTPATH}/tpcds-v2.13.0rc1/tools
    mkdir -p ${TOOLS_PATH}
    cp -r $SOURCE_PATH/* ${TOOLS_PATH}
	cd $TOOLS_PATH
	make OS=LINUX
	cd -
}

gen_data() {
	local TOOLS_PATH=${SCRIPTPATH}/build/tools
	if [ ! -f ${TOOLS_PATH}/dsdgen ]; then
        build_tools
	fi
	export CSVPATH=${SCRIPTPATH}/data_csv_$SIZE
	$TOOLS_PATH/dgen.sh $SIZE
	[ $SIZE -eq 1 ] && cp tpcds1_fix/web_page.dat $CSVPATH || true
	if [ "$REPLACE_FLAG"x == "1"x ]; then
		for f in $(ls $CSVPATH); do
			echo "Replacing  empty cell in $CSVPATH/$f"
			sed -i "s#||#|\\\N|#g;s#||#|\\\N|#g" $CSVPATH/$f
		done
	fi
}

[ -z $SIZE ] && usage && exit 1
gen_data