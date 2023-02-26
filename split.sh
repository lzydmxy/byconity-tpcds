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
