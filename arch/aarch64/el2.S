.section .text.boot
.globl _el2_start
.type _el2_start, %function

.section .rodata
first_el2_jump_msg:
    .asciz "[AXIOM] : [EL2]: EL3 eret into EL2\n"



_el2_start:
	
	// NOTE: EL2 stack comes established from EL3's handoff sequence
	ldr x0, =first_el2_jump_msg
	bl console_puts

	// read CurrentEL for verification
	mrs x1, CurrentEL	
	
1: 
	b 1b

