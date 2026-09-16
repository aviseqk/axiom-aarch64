#include "arch/el2.h"
#include "arch/el1.h"
#include "generated/el1-build-layout.h"


/* Helper macro to load arbitrary values into 64-bit registers which generates the mov/movk combinations. 
because we cannot load a general arbitraty 64 bit constant value using a single instruction in aarch64
movz establishes the initial value and movk replace one 16-bit portion without disturbing the others */
.macro mov_imm reg, value
    movz \reg, ((\value >> 0)  & 0xffff)
    movk \reg, ((\value >> 16) & 0xffff), lsl #16
    movk \reg, ((\value >> 32) & 0xffff), lsl #32
    movk \reg, ((\value >> 48) & 0xffff), lsl #48
.endm

.section .rodata
first_el2_jump_msg:
    .asciz "[AXIOM] : [EL2]: EL3 eret into EL2\n"

before:
    .asciz "[AXIOM] : [EL2]: before\n"

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
	ldr x0, =__el2_bss_start
	ldr x1, =__el2_bss_end

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

	bl prepare_axiom_enter_el1	

	eret



/* prepare the exception return and context for CPU to jump to EL1 */
prepare_axiom_enter_el1:
	
	// EL1 must execute AArch64.
	mrs     x0, HCR_EL2
	orr     x0, x0, #HCR_EL2_RW_BIT       // HCR_EL2.RW
	msr     HCR_EL2, x0
	isb
	
	// prepare EL1's stack
	ldr x0, =AXIOM_EL1_STACK_TOP
	msr SP_EL1, x0

	// program the EL1's execution environment i.e. SCTLR_EL1
	mov_imm x0, (SCTLR_EL1_RESET_VAL & ~(SCTLR_EE_BIT | SCTLR_WXN_BIT \
			| SCTLR_I_BIT | SCTLR_NAA_BIT | SCTLR_C_BIT \
			| SCTLR_A_BIT | SCTLR_M_BIT))
	orr x0, x0, #SCTLR_SA_BIT
	msr SCTLR_EL1, x0
	isb

	// prepare the EL2 return state, SPSR_EL2
	mov_imm x0, SPSR_EL2_M_EL1h

	orr x0, x0, #SPSR_EL2_D_BIT
	orr x0, x0, #SPSR_EL2_A_BIT
	orr x0, x0, #SPSR_EL2_I_BIT
	orr x0, x0, #SPSR_EL2_F_BIT

	msr SPSR_EL2, x0

	// setup VBAR_EL1 for EL1
	ldr x0, =AXIOM_EL1_VECTOR_BASE
	msr VBAR_EL1, x0
	isb

	// assign the entrypoint address of EL1
	ldr x0, =AXIOM_EL1_ENTRY
	msr ELR_EL2, x0

	ret
