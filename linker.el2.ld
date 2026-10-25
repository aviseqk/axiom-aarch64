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

	.text : ALIGN(4096)
	{
		__el2_text_start = .;
		KEEP(*(.text.boot))
		*(.text*)
		__el2_text_end = .;
	} > EL2_DRAM

	.vectors : ALIGN(4096)
	{
		__el2_vector_table_start = .;
		KEEP(*(.vectors))
		__el2_vector_table_end = .;
	} > EL2_DRAM

	.rodata : ALIGN(4096)
	{
		__el2_rodata_start = .;
		*(.rodata*)
		__el2_rodata_end = .;
	} > EL2_DRAM
	
	/* TODO: Page boundaries are needed only when the MMU policy changes,
	 * so in theory we could have the page-granular boundary alignment being 
	 * shared between similar ELF sections like .data, .bss, and .stack instead
	 * of each of those sections being 4KiB page-aligned we could have the whole
	 * of it as a contiguous section and page-aligned
	 * */
	.data : ALIGN(4096)
	{
		__el2_data_start = .;
		*(.data*)
		__el2_data_end = .;
	} > EL2_DRAM

	__el2_data_load = LOADADDR(.data);

	.bss (NOLOAD) : ALIGN(4096)
	{
		__el2_bss_start = .;
		*(.bss*)
		*(COMMON)
		__el2_bss_end = .;
	} > EL2_DRAM

	.stack (NOLOAD) : ALIGN(4096)
	{
		__el2_stack_bottom = .;
		. += AXIOM_EL2_STACK_SIZE;
		__el2_stack_top = .;
	} > EL2_DRAM

	.translation_tables (NOLOAD) : ALIGN(4096)
	{
		__el2_translation_tables_start = .;

		KEEP(*(.translation_tables))

		__el2_translation_tables_end = .;
	} > EL2_DRAM

	__el2_image_end = .;

	ASSERT(__el2_data_load == __el2_data_start,
		"Axiom EL2 .data LMA differs from VMA")

	ASSERT(__el2_vector_table_start % 2048 == 0,
		"Axiom EL2 Vector Table not 2KiB aligned")

	ASSERT(__el2_vector_table_end - __el2_vector_table_start == 0x800,
		"Axiom EL2 Vector Table is not 2KiB in size")
	
	ASSERT(__el2_translation_tables_start % 4096 == 0,
		"Axiom EL2 translation tables are not 4KiB aligned")

	ASSERT(__el2_translation_tables_end - __el2_translation_tables_start == 0x8000,
		"Axiom EL2 translation tables are not 32KiB in size, for this setup")

	ASSERT(__el2_image_end <= AXIOM_EL2_BASE + AXIOM_EL2_SIZE,
		"Axiom EL2 DRAM Memory Allocation Overflow")

}

/* EL2 -> EL3 handoff ABI */
__axiom_el2_entry = _el2_start;
__axiom_el2_vector_base = __el2_vector_table_start;
__axiom_el2_stack_top = __el2_stack_top;
