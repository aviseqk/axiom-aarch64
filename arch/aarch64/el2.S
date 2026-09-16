.section .rodata
first_el2_jump_msg:
    .asciz "[AXIOM] : [EL2]: EL3 eret into EL2\n"


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

	bl el2_main
	
1: 
	b 1b
