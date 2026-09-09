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
	/* QEMU at reset gives us this for SCTLR_EL3, SCR_EL3, VBAR_EL3, DAIF respectively
		0x0000000000000018 in _start ()
		(gdb) info registers x1 x2 x3 x4
		x1             0xc50838            12912696	//SCTLR_EL3
		x2             0x30                48		//SCR_EL3
		x3             0x0                 0		//VBAR_EL3
		x4             0x3c0               960		//DAIF

	*/

	// install the VBAR_EL3 with our defined vector_table
	ldr x0, =vector_table
	msr VBAR_EL3, x0
	isb

	// testing our exception hookup - by deliberately triggering a synchronous exception - by undefined instruction
	// udf #0


1:
	b 1b
