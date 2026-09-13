.section .text.boot
.globl _el2_start
.type _el2_start, %function

_el2_start:
	
	// NOTE: EL2 stack comes established from EL3's handoff sequence

	// read CurrentEL for verification
	mrs x1, CurrentEL	

1: 
	b 1b

