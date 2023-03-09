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