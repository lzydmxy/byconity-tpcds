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
DST=${1:-output}
MAX_SZ=${2:-512M}

verify_dst() {
    local FILE=""
    local DIR="$1"
    # init
    # look for empty dira
    if [ -d "$DIR" ]; then
        if [ "$(ls -A $DIR)" ]; then
            echo "$DIR is not empty"
            exit 1
        fi
    else
        mkdir -p "$DIR"
    fi
}

verify_dst "${DST}"
echo "split ${PWD} into ${DST} directory, size limit of single file is ${MAX_SZ}"
for f in *; do
    [ -d "$f" ] && continue
    filename=$(basename -- "$f")
    extension="${filename##*.}"
    filename="${filename%.*}"
    [ "$extension" == "sh" ] && continue

    echo "Splitting ${f}..."
    split -a 6 --additional-suffix=.${extension} -d -C${MAX_SZ} ${f} ${DST}/${filename}_
done
