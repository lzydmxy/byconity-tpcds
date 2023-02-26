#!/bin/bash
source ./config.sh
source ./helper.sh

[ -z "$1" ] && DATASIZE=1 || DATASIZE=$1
[ -z "$2" ] && CSVPATH="$SCRIPTPATH/data_${SUITE}_${DATASIZE}" || CSVPATH=$2

DATABASE=${DATABASE:-${DB_PREFIX}${SUITE}${DATASIZE}${DB_SUFFIX}}
EXT=dat
DELIM="|"

if [ ! -d $CSVPATH ]; then
    log "$CSVPATH directory not found."
    exit -1
fi

set -e

log "Create tables for ${DATABASE}..."
if [ -n "$BUCKET_SIZE" ]; then
	log "Use bucket table. "
	CNCH_DDL=$SCRIPTPATH/ddl/byconity-bucket.sql
else
	CNCH_DDL=$SCRIPTPATH/ddl/byconity.sql
fi
CNCH_DDL=$(sed "s|${SUITE}|${DATABASE}|g; s|__BUCKET_SIZE__|${BUCKET_SIZE}|g" ${CNCH_DDL})
clickhouse_client "${CNCH_DDL}"

log "Import dataset from ${CSVPATH}..."
TABLES=$(show_tables "$DATABASE")
log "Tables created: $TABLES"

FILE_TABLES=()
FILE_NAMES=()
for TABLE in $TABLES; do
    FILE=${CSVPATH}/${TABLE}.${EXT}

	if [ -f "${FILE}" ]; then
		FILE_TABLES+=(${TABLE})
		FILE_NAMES+=(${FILE})
	else
		for f in `find ${CSVPATH}/ -regex "${CSVPATH}/${TABLE}_[0-9_]+\.${EXT}"`; do
			FILE_TABLES+=(${TABLE})
			FILE_NAMES+=(${f})
		done
	fi
done

ARGS=" -d $DATABASE --input_format_defaults_for_omitted_fields=1 --format_csv_delimiter='$DELIM' --input_format_parallel_parsing=1"
CMDS=()
for i in ${!FILE_NAMES[@]}; do
	SQL="INSERT INTO ${FILE_TABLES[$i]} FORMAT CSV"
	CMD=$(clickhouse_client_cmd "$SQL" "$ARGS < ${FILE_NAMES[$i]}")
	if [ -n "$ENABLE_TRACE" ]; then
        trace "$CMD"
    fi
    CMDS+=("${CMD} && echo uploaded ${FILE_NAMES[$i]} || exit 1")
done

if [ -z "$PARALLEL" ]; then
    PARALLEL=$(($(grep -c ^processor /proc/cpuinfo)/2))
    if (( PARALLEL < 2 )); then
        PARALLEL=2
    fi
fi

log "set PARALLEL ${PARALLEL}"

SECONDS=0
printf "%s\n" "${CMDS[@]}" | tr '\n' '\0' | xargs -0 -P${PARALLEL} -n 1 -I {} sh -c "{}"
log "Used ${SECONDS}s to import ${DATABASE}."


# check row counts 
select_count() {
	clickhouse_client "SELECT COUNT(*) FROM $1"
}

case $DATASIZE in
	1)	
		ROW_CNT=(call_center-6 catalog_page-11718 catalog_returns-143974 catalog_sales-1440839 customer-100000 customer_address-50000 customer_demographics-1920800 date_dim-73049 household_demographics-7200 income_band-20 inventory-11745000 item-18000 promotion-300 reason-35 ship_mode-20 store-12 store_returns-287777 store_sales-2880029 time_dim-86400 warehouse-5 web_page-60 web_returns-71937 web_sales-720791 web_site-30)
		;;
	100)
		ROW_CNT=(call_center-30 catalog_page-20400 catalog_returns-14404374 catalog_sales-143997065 customer-2000000 customer_address-1000000 customer_demographics-1920800 date_dim-73049 household_demographics-7200 income_band-20 inventory-399330000 item-204000 promotion-1000 reason-55 ship_mode-20 store-402 store_returns-28795080 store_sales-287997024 time_dim-86400 warehouse-15 web_page-2040 web_returns-7197670 web_sales-72001237 web_site-24)
		;;
	1000)
		ROW_CNT=(call_center-42 catalog_page-30000 catalog_returns-143996756 catalog_sales-1439980416 customer-12000000 customer_address-6000000 customer_demographics-1920800 date_dim-73049 household_demographics-7200 income_band-20 inventory-783000000 item-300000 promotion-1500 reason-65 ship_mode-20 store-1002 store_returns-287999764 store_sales-2879987999 time_dim-86400 warehouse-20 web_page-3000 web_returns-71997522 web_sales-720000376 web_site-54)
esac

for CNT in ${ROW_CNT[@]}; do
	IFS=- read -r TABLE ROW <<< "${CNT}" && unset IFS

	IMPORTED_COUNT=$(clickhouse_client "SELECT COUNT(*) FROM ${TABLE}" -d ${DATABASE})
	FAILURE=0
	if [[ "${IMPORTED_COUNT}" != "${ROW}" ]]; then
		# As long as 1 table fails, we will trigger FAILURE
		log "${TABLE} should have ${IMPORTED_COUNT} instead has ${ROW}"
		FAILURE=1
	else
		log "${TABLE} count matches expectation."
	fi 
done 

if [[ "${FAILURE}" == "1" ]]; then 
	log "Imported rows do not match the required amount. Terminating."
	exit 1
fi 
log "All tables imported matches expectation."

