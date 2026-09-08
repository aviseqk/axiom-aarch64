#include "axiom-memory.h"

MEMORY
{
	BOOTROM (rx): ORIGIN = AXIOM_BOOTROM_BASE, LENGTH = AXIOM_BOOTROM_SIZE
	SECURE_RAM( rwx): ORIGIN = AXIOM_EARLY_SECURE_RAM_BASE, LENGTH = AXIOM_EARLY_SECURE_RAM_SIZE
}

ENTRY(_start)

SECTIONS
{
	. = AXIOM_BOOTROM_BASE;

	.text : ALIGN(4)
	{
		KEEP(*(.text.boot))
		*(.text*)		/* NOTE: this also includes the .text.exceptions the handlers section */
	} > BOOTROM

	.vectors : ALIGN(2048)
	{
		__vector_table_start = .;
		KEEP(*(.vectors))
		__vector_table_end = .;
	} > BOOTROM

	.rodata : ALIGN(8)
	{
		*(.rodata*)
	} > BOOTROM
	
	. = AXIOM_EARLY_SECURE_RAM_BASE;	/* Move to secure RAM for mutable data/stack */

	.data : ALIGN(8)
	{
		__data_start = .;
		*(.data*)
		__data_end = .;
	} > SECURE_RAM AT>BOOTROM

	__data_load = LOADADDR(.data);

	.bss (NOLOAD): ALIGN(8)
	{
		__bss_start = .;
		*(.bss*)
		*(COMMON)
		__bss_end = .;
	} > SECURE_RAM

	.stack (NOLOAD): ALIGN(16)
	{
		__stack_bottom = .;
		. += AXIOM_STACK_SIZE;
		__stack_top = .;
	} > SECURE_RAM

	/* Link-time safety checks */
	ASSERT(__stack_top <= AXIOM_EARLY_SECURE_RAM_BASE + AXIOM_EARLY_SECURE_RAM_SIZE,
		"Axiom secure RAM overflow")

	ASSERT(__vector_table_start % 2048 == 0,
		"Level1 Vector Table not 2KiB aligned")

	ASSERT(__vector_table_end - __vector_table_start == 0x800,
		"Level1 Vector Table is not 2KiB in size")
}
