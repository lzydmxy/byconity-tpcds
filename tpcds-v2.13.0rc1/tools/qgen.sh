#!/bin/sh

[ -z "$1" ] && DATASIZE=1 || DATASIZE=$1

OUTPUT="../../q_tpcds${DATASIZE}"
[ -d $OUTPUT ] || mkdir $OUTPUT

for f in ../query_templates/query*.tpl; do
	name=`basename -s .tpl $f`
	name=${name#query}
	[ ${#name} -eq 1 ] && name="0${name}" || name=${name}

	./dsqgen \
		-TEMPLATE $f \
		-DIRECTORY ../query_templates \
		-VERBOSE Y \
		-QUALIFY Y \
		-SCALE $DATASIZE \
		-DIALECT netezza \
		-OUTPUT $OUTPUT
	mv $OUTPUT/query_0.sql $OUTPUT/$name.sql
done
