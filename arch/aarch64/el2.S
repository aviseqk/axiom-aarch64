section .rodata
first_el2_jump_msg:
    .asciz "[AXIOM] : [EL2]: EL3 eret into EL2\n"

.section .rodata
before:
    .asciz "[AXIOM] : [EL2]: before\n"

.section .rodata
after:
    .asciz "[AXIOM] : [EL2]: after\n"

.macro udf_inst_exception_test_hook
	// TEST: the following 5 instructions are there as a part of exception route testing only

	ldr x0, =before
	bl console_puts

	udf #0
	
	ldr x0, =after
	bl console_puts	

.endm

.section .text.boot
.globl _el2_start
.type _el2_start, %function

_el2_start:
	// NOTE: EL2 stack comes established from EL3's handoff sequence

	// zero bss
	ldr x0, __el2_bss_start
	ldr x1, __el2_bss_end

zero_bss:
	cmp x0, x1
	b.hs end_zero_bss
	str xzr, [x0], #8
	b zero_bss

end_zero_bss:

	ldr x0, =first_el2_jump_msg
	bl console_puts

	udf_inst_exception_test_hook

	bl el2_main
	
1: 
	b 1b
