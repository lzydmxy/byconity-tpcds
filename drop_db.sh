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
source ./helper.sh

[ -z "$1" ] && DATASIZE=1 || DATASIZE=$1

function drop_database() {
	local DB=$1
	local TABLES=$(show_tables "$DB")

	if [ -n "${TABLES}" ]; then
		for TABLE in ${TABLES}; do
			echo "Drop ${DB}.${TABLE}..."
			clickhouse-client -d "$DB" -q "DROP TABLE IF EXISTS ${TABLE}${POSTFIX};" > /dev/null
		done

		echo "Drop ${DB}..."
		clickhouse-client -q "DROP DATABASE IF EXISTS \`${DB}${POSTFIX}\`;" > /dev/null
	fi
}

[ -z "$1" ] && DATASIZE=1 || DATASIZE=$1
export DATABASE=${DATABASE:-${DB_PREFIX}${SUITE}${DATASIZE}}

if [ -n "$ENABLE_OPTIMIZER" ]; then
	clickhouse-client -d "$DATABASE" -q "drop stats" 2>/dev/null || true
fi

set +e
drop_database $DATABASE