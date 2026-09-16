.section .rodata
first_el1_jump_msg:
    .asciz "[AXIOM] : [EL1]: EL2 eret into EL1\n"

after_hvc_msg:
    .asciz "[AXIOM] : [EL1]: returned from HVC\n"

before_udf_msg:	
    .asciz "[AXIOM] : [EL1]: before UDF\n"

after_udf_msg:	
    .asciz "[AXIOM] : [EL1]: after UDF\n"


.macro hvc_exception_test_hook
	/*  TEST: the following instructions are there as a part of HVC exception route testing in EL1. 
	This is just a naive HVC round-trip test, and there is no service dispatch or context construction involved yet,
	because we have not implemented any HVC service yet that needs it. The path is that at HVC, execution jumps to EL2,
	and ELR_EL2 is saved as instrution following the HVC call, so the EL2 excepiton handler for `Lower EL using AArch64`
	does nothing, but simply just eret, as that depends heavily on the HVC ABI, and we can simply eret as the ELR_EL2 is already properly setup
	*/

	hvc #0
	
	ldr x0, =after_hvc_msg
	bl console_puts	

.endm

.macro udf_inst_exception_test_hook
	/*  TEST: the following instructions are there as a part of udf exception route testing in EL1. */
	ldr x0, =before_udf_msg
	bl console_puts	
	
	udf #0
	
	ldr x0, =after_udf_msg
	bl console_puts	

.endm


.section .text.boot
.globl _el1_start
.type _el1_start, %function

_el1_start:
	
	mrs x0, CurrentEL
	// INFO: EL1 stack comes established from EL2's handoff sequence

	// zero bss
	ldr x0, =__el1_bss_start
	ldr x1, =__el1_bss_end

zero_bss:
	cmp x0, x1
	b.hs end_zero_bss
	str xzr, [x0], #8
	b zero_bss

end_zero_bss:

	ldr x0, =first_el1_jump_msg
	bl console_puts

	hvc_exception_test_hook	

	//udf_inst_exception_test_hook

	bl el1_main

1:
	b 1b
