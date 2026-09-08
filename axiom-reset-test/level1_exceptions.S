/* Basic Exception Handlers Used by Axiom at Level 1 in EL3 */

// TODO: right now, all the exception handlers (vectors) branch to just one same handler, change that post exception-routing debug test from gdb

// TODO: manually added .space 0x7c commands can be outsourced to a ASM macro that either self calculates the delta space needed, and adds it behind the scenes
// or follow TF-A's way of defining ASM macros like vector_base, vector_entry, end_vector_entry that takes care of the memory space placement

// TODO: at this level 1 axiom firmware level, decide which exceptions are not worth servicing, like as seen in TF-A BL1 a lot of exceptions just lead to plat_panic_handler

.section .vectors, "ax"
.align 11
.globl vector_table

vector_table:

	// Current EL with SP0
	b vector_handler
	.space 0x7c
	b vector_handler
	.space 0x7c
	b vector_handler
	.space 0x7c
	b vector_handler
	.space 0x7c

	// Current EL with SPx
	b vector_handler
	.space 0x7c
	b vector_handler
	.space 0x7c
	b vector_handler
	.space 0x7c
	b vector_handler
	.space 0x7c

	// Lower EL using AArch64
	b vector_handler
	.space 0x7c
	b vector_handler
	.space 0x7c
	b vector_handler
	.space 0x7c
	b vector_handler
	.space 0x7c

	// Lower EL using AArch32
	b vector_handler
	.space 0x7c
	b vector_handler
	.space 0x7c
	b vector_handler
	.space 0x7c
	b vector_handler
	.space 0x7c

.section .text.exceptions, "ax"
.globl vector_handler

vector_handler:
	b vector_handler
