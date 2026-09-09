#include "platform/axiom-memory.h"

MEMORY
{
	BOOTROM (rx): 
		ORIGIN = AXIOM_BOOTROM_BASE,
		LENGTH = AXIOM_BOOTROM_SIZE

	SECURE_RAM( rwx):
		ORIGIN = AXIOM_EARLY_SECURE_RAM_BASE, 
		LENGTH = AXIOM_EARLY_SECURE_RAM_SIZE
}

ENTRY(_start)

SECTIONS
{
	. = AXIOM_BOOTROM_BASE;

	.text : ALIGN(4)
	{
		KEEP(*(.text.boot))
		*(.text.*)
	} > BOOTROM

	. = AXIOM_EARLY_SECURE_RAM_BASE;	/* move to secure RAM for mutable data/stack */

	.stack (NOLOAD): ALIGN(16)
	{
		__stack_bottom = .;
		. += AXIOM_STACK_SIZE;
		__stack_top = .;
	} > SECURE_RAM

	/* Link-time safety checks */
	ASSERT(__stack_top <= AXIOM_EARLY_SECURE_RAM_BASE + AXIOM_EARLY_SECURE_RAM_SIZE,
		"Axiom secure RAM overflow")
}
