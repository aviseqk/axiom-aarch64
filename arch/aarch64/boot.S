.section .text.boot
.globl _start
.type _start, %function


_start:
	// prepare the EL3 stack
	ldr x0, =__stack_top
	mov sp, x0

	// read and observe the current CPU State
	mrs x1, SCTLR_EL3
	mrs x2, SCR_EL3
	mrs x3, VBAR_EL3
	mrs x4, DAIF

1:
	b 1b
