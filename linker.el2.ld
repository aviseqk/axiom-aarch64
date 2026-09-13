#include "platform/axiom-memory.h"

MEMORY
{
	EL2_DRAM (rwx):
		ORIGIN = AXIOM_EL2_BASE,
		LENGTH = AXIOM_EL2_SIZE
}

ENTRY(_el2_start)

SECTIONS
{
	. = AXIOM_EL2_BASE;

	.text : ALIGN(4)
	{
		KEEP(*(.text.boot))
		*(.text*)
	} > EL2_DRAM

	.vectors : ALIGN(2048)
	{
		__el2_vector_table_start = .;
		KEEP(*(.vectors))
		__el2_vector_table_end = .;
	} > EL2_DRAM

	.rodata : ALIGN(8)
	{
		*(.rodata*)
	} > EL2_DRAM

	.data : ALIGN(8)
	{
		__el2_data_start = .;
		*(.data*)
		__el2_data_end = .;
	} > EL2_DRAM

	__el2_data_load = LOADADDR(.data);

	.bss (NOLOAD) : ALIGN(8)
	{
		__el2_bss_start = .;
		*(.bss*)
		*(COMMON)
		__el2_bss_end = .;
	} > EL2_DRAM

	.stack (NOLOAD) : ALIGN(16)
	{
		__el2_stack_bottom = .;
		. += AXIOM_EL2_STACK_SIZE;
		__el2_stack_top = .;
	} > EL2_DRAM

	__el2_image_end = .;

	ASSERT(__el2_data_load == __el2_data_start,
		"Axiom EL2 .data LMA differs from VMA")

	ASSERT(__el2_vector_table_start % 2048 == 0,
		"Axiom EL2 Vector Table not 2KiB aligned")

	ASSERT(__el2_vector_table_end - __el2_vector_table_start == 0x800,
		"Axiom EL2 Vector Table is not 2KiB in size")

	ASSERT(__el2_image_end <= AXIOM_EL2_BASE + AXIOM_EL2_SIZE,
		"Axiom EL2 DRAM Memory Allocation Overflow")
}

/* EL2 -> EL3 handoff ABI */
__axiom_el2_entry = _el2_start;
__axiom_el2_vector_base = __el2_vector_table_start;
__axiom_el2_stack_top = __el2_stack_top;
