#!/usr/bin/env bash

set -e

ELF="$1"
HEADER="include/generated/el2-build-layout.h"

REQUIRED_SYMBOLS=(
	"__axiom_el2_entry"
	"__axiom_el2_stack_top"
	"__axiom_el2_vector_base"
	)

nm_output=$(aarch64-none-elf-nm --defined-only --format=posix "$ELF")

for symbol in "${REQUIRED_SYMBOLS[@]}"; do
    if ! echo "$nm_output" |
        awk -v sym="$symbol" '$1 == sym && $3 ~ /^[0-9a-fA-F]+$/ { found=1 }
                              END { exit !found }'; then
        echo "ERROR: required EL2 ABI symbol        $symbol        was not found in $ELF" >&2
        exit 1
    fi
done

{
	echo "/* Automatically generated from el2-entry.elf by generate-el2-layout.sh. */"
	echo "/* DO NOT EDIT.! */"
	echo
	echo "#ifndef AXIOM_EL2_LAYOUT_H"
	echo "#define AXIOM_EL2_LAYOUT_H"
	echo

	echo "$nm_output" |
		awk '$1 ~ /^__axiom/ {
           		name = $1
            		sub(/^__/, "", name)
            		printf "#define %-32s 0x%s\n", toupper(name), $3
        	}'

    	echo
	echo "#endif /* AXIOM_EL2_LAYOUT_H */"
} > "$HEADER"


echo "Generated $HEADER successfully!"
