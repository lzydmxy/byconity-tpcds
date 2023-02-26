#!/bin/bash
set -e
source ./helper.sh

build_tools() {
    local SOURCE_PATH=${SCRIPTPATH}/tpcds-v2.13.0rc1/tools
    mkdir -p ${TOOLS_PATH}
    cp -r $SOURCE_PATH/* ${TOOLS_PATH}
	cd $TOOLS_PATH
	make OS=LINUX
	cd -
}

if [ -f ${TOOLS_PATH}/dsdgen ]; then
    rm -r ${TOOLS_PATH} 
fi
build_tools