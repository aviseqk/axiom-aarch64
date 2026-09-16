#!/usr/bin/env bash

set -e

STAGE="$1"
ELF="$2"

case "$STAGE" in
	el1|el2)
		;;
	*)
		echo "Usage: $0 <el1|el2> <elf_filename>" >&2
		exit 1
		;;
esac

if [[ -z "$ELF" ]]; then
    echo "ERROR: ELF file was not specified" >&2
    echo "Usage: $0 <el1|el2> <elf>" >&2
    exit 1
fi

STAGE_PREFIX="${STAGE^^}"
HEADER="include/generated/${STAGE}-build-layout.h"

REQUIRED_SYMBOLS=(
	"__axiom_${STAGE}_entry"
	"__axiom_${STAGE}_stack_top"
	"__axiom_${STAGE}_vector_base"
	)

nm_output=$(aarch64-none-elf-nm --defined-only --format=posix "$ELF")

for symbol in "${REQUIRED_SYMBOLS[@]}"; do
    if ! echo "$nm_output" |
        awk -v sym="$symbol" '$1 == sym && $3 ~ /^[0-9a-fA-F]+$/ { found=1 }
                              END { exit !found }'; then
        echo "ERROR: required ${STAGE_PREFIX} ABI symbol        $symbol        was not found in $ELF" >&2
        exit 1
    fi
done

{
	echo "/* Automatically generated from $ELF by generate-el-layout.sh. */"
	echo "/* DO NOT EDIT.! */"
	echo
	echo "#ifndef AXIOM_${STAGE_PREFIX}_LAYOUT_H"
	echo "#define AXIOM_${STAGE_PREFIX}_LAYOUT_H"
	echo

	echo "$nm_output" |
		awk '$1 ~ /^__axiom/ {
           		name = $1
            		sub(/^__/, "", name)
            		printf "#define %-32s 0x%s\n", toupper(name), $3
        	}'

    	echo
	echo "#endif /* AXIOM_${STAGE_PREFIX}_LAYOUT_H */"
} > "$HEADER"


echo "Generated $HEADER successfully!"
