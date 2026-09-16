#include "platform/axiom-memory.h"

MEMORY
{
	EL1_DRAM (rwx):
		ORIGIN = AXIOM_EL1_BASE,
		LENGTH = AXIOM_EL1_SIZE
}

ENTRY(_el1_start)

SECTIONS
{
	. = AXIOM_EL1_BASE;

	.text : ALIGN(4)
	{
		KEEP(*(.text.boot))
		*(.text*)
	} > EL1_DRAM

	.vectors : ALIGN(2048)
	{
		__el1_vector_table_start = .;
		KEEP(*(.vectors))
		__el1_vector_table_end = .;
	} > EL1_DRAM

	.rodata : ALIGN(8)
	{
		*(.rodata*)
	} > EL1_DRAM

	.data : ALIGN(8)
	{
		__el1_data_start = .;
		*(.data*)
		__el1_data_end = .;
	} > EL1_DRAM

	__el1_data_load = LOADADDR(.data);

	.bss (NOLOAD) : ALIGN(8)
	{
		__el1_bss_start = .;
		*(.bss*)
		*(COMMON)
		__el1_bss_end = .;
	} > EL1_DRAM

	.stack (NOLOAD) : ALIGN(16)
	{
		__el1_stack_bottom = .;
		. += AXIOM_EL1_STACK_SIZE;
		__el1_stack_top = .;
	} > EL1_DRAM

	__el1_image_end = .;

	ASSERT(__el1_data_load == __el1_data_start,
		"Axiom EL1 .data LMA differs from VMA")

	ASSERT(__el1_vector_table_start % 2048 == 0,
		"Axiom EL1 Vector Table not 2KiB aligned")

	ASSERT(__el1_vector_table_end - __el1_vector_table_start == 0x800,
		"Axiom EL1 Vector Table is not 2KiB in size")

	ASSERT(__el1_image_end <= AXIOM_EL1_BASE + AXIOM_EL1_SIZE,
		"Axiom EL1 DRAM Memory Allocation Overflow")
}

/* EL1 -> EL2 handoff ABI */
__axiom_el1_entry = _el1_start;
__axiom_el1_vector_base = __el1_vector_table_start;
__axiom_el1_stack_top = __el1_stack_top;
