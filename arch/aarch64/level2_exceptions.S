.section .vectors, "ax"
.align 11
.globl _el2_vectors_placeholder

// TODO: just a placeholder storage for vector table, add actual vectors later
_el2_vectors_placeholder:
	.space 0x800
