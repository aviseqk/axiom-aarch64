#include "arch/exceptions.h"
#include "generated/axiom-exception-ctx-offset.h"

.macro save_gprs

	stp x0, x1, [sp, #AX_CTX_X0]
	stp x2, x3, [sp, #AX_CTX_X2]
	stp x4, x5, [sp, #AX_CTX_X4]
	stp x6, x7, [sp, #AX_CTX_X6]
	stp x8, x9, [sp, #AX_CTX_X8]
	stp x10, x11, [sp, #AX_CTX_X10]
	stp x12, x13, [sp, #AX_CTX_X12]
	stp x14, x15, [sp, #AX_CTX_X14]
	stp x16, x17, [sp, #AX_CTX_X16]
	stp x18, x19, [sp, #AX_CTX_X18]
	stp x20, x21, [sp, #AX_CTX_X20]
	stp x22, x23, [sp, #AX_CTX_X22]
	stp x24, x25, [sp, #AX_CTX_X24]
	stp x26, x27, [sp, #AX_CTX_X26]
	stp x28, x29, [sp, #AX_CTX_X28]
	str x30, [sp, #AX_CTX_X30]

.endm

.macro save_sysregs

	mrs x0, elr_el2
	str x0, [sp, #AX_CTX_ELR]
	mrs x0, spsr_el2
	str x0, [sp, #AX_CTX_SPSR]
	mrs x0, esr_el2
	str x0, [sp, #AX_CTX_ESR]
	mrs x0, far_el2
	str x0, [sp, #AX_CTX_FAR]

.endm

.macro restore_gprs

	ldp x0, x1, [sp, #AX_CTX_X0]
	ldp x2, x3, [sp, #AX_CTX_X2]
	ldp x4, x5, [sp, #AX_CTX_X4]
	ldp x6, x7, [sp, #AX_CTX_X6]
	ldp x8, x9, [sp, #AX_CTX_X8]
	ldp x10, x11, [sp, #AX_CTX_X10]
	ldp x12, x13, [sp, #AX_CTX_X12]
	ldp x14, x15, [sp, #AX_CTX_X14]
	ldp x16, x17, [sp, #AX_CTX_X16]
	ldp x18, x19, [sp, #AX_CTX_X18]
	ldp x20, x21, [sp, #AX_CTX_X20]
	ldp x22, x23, [sp, #AX_CTX_X22]
	ldp x24, x25, [sp, #AX_CTX_X24]
	ldp x26, x27, [sp, #AX_CTX_X26]
	ldp x28, x29, [sp, #AX_CTX_X28]
	ldr x30, [sp, #AX_CTX_X30]

.endm


.section .rodata
el2_sync_exception_log:
    .asciz "[EL2]: synchronous exception\n"

.section .rodata
el2_sync_lowerel_log:
    .asciz "[EL2]: synchronous exception from lower EL ig EL1 \n"

/* Exception Handlers used by Axiom at Level 2 in EL2 */

.section .vectors, "ax"
.align 11
.globl el2_vector_table

el2_vector_table:

	// Current EL with SP0
	mov x0, #SYNC_EXCEPTION_SP0
	b el2_sync_entry	// Synchronous Exceptions
	.space 0x78
	mov x0, #IRQ_SP0
	b el2_irq_entry		// IRQs
	.space 0x78
	mov x0, #FIQ_SP0
	b el2_fiq_entry		// FIQs
	.space 0x78
	mov x0, #SERROR_SP0
	b el2_serror_entry	// SErrors	
	.space 0x78


	// Current EL with SPx
	mov x0, #SYNC_EXCEPTION_SPX
	b el2_sync_entry	
	.space 0x78
	mov x0, #IRQ_SPX
	b el2_irq_entry
	.space 0x78
	mov x0, #FIQ_SPX
	b el2_fiq_entry
	.space 0x78
	mov x0, #SERROR_SPX
	b el2_serror_entry
	.space 0x78


	// Lower EL using AArch64
	mov x0, #SYNC_EXCEPTION_AARCH64
	b el2_sync_entry
	.space 0x78
	mov x0, #IRQ_AARCH64
	b el2_irq_entry
	.space 0x78
	mov x0, #FIQ_AARCH64
	b el2_fiq_entry
	.space 0x78
	mov x0, #SERROR_AARCH64
	b el2_serror_entry
	.space 0x78
	

	// Lower EL using AArch32
	mov x0, #SYNC_EXCEPTION_AARCH32
	b el2_sync_entry
	.space 0x78
	mov x0, #IRQ_AARCH32
	b el2_irq_entry
	.space 0x78
	mov x0, #FIQ_AARCH32
	b el2_fiq_entry
	.space 0x78
	mov x0, #SERROR_AARCH32
	b el2_serror_entry
	.space 0x78


.section .text.exceptions, "ax"

el2_sync_entry:
	cmp x0, #SYNC_EXCEPTION_AARCH64		// if an HVC call?
	b.ne not_lower_el_sync

	// TODO: The reason why I have not yet introduced the context mechanism in this path,  saving and restoring registers
	// because that would be heavily driven by HVC service ABI, when it is implemented right. Also EL1 never sees this exception, so EL1 cant save it.
	
	ldr x0, =el2_sync_lowerel_log
	bl console_puts

	eret

not_lower_el_sync:
	
	ldr x0, =el2_sync_exception_log
	bl console_puts
	
	sub sp, sp, #AX_CTX_SIZE	// allocated the stack frame for exception context

	save_gprs		// saving the GPRs
	
	// saving the SP by restoring the pre-exception-frame SP
	add x0, sp, #AX_CTX_SIZE
	str x0, [sp, #AX_CTX_SP]

	save_sysregs		// saving exception system registers

	mov x0, sp		// assigning context frame's start as x0 register for C function as per function calling convention

	bl axiom_exception_dispatch

	/* we have returned from exception handling, time to restore the state back
	* NOTE: exception state registers like ESR and FAR, are not needed as a part of ERET return state, as they contain information about said exception. */

	ldr x0, [sp, #AX_CTX_ELR]	// restore the exception return registers
	msr elr_el2, x0

	ldr x0, [sp, #AX_CTX_SPSR]
	msr spsr_el2, x0

	restore_gprs		// restore the general purpose registers
	
	/*  TODO: The interrupted SP is currently not mutable through the C context. The exception frame is allocated from SP_EL2 itself, 
	so the original SP is recovered by releasing AX_CTX_SIZE bytes, use a different exception-handler stack later to allow C context's SP to be modified 
	- Refer docs/stack-for-exception-handling.md file for more details */

	add sp, sp, #AX_CTX_SIZE		// restore the pre-exception stack pointer and release exception context stack frame

	eret

el2_unhandled_exception:
1:
	b 1b

// TODO: IRQ handling needs the interrupt controller, GIC runtime support, currently unimplemented
el2_irq_entry:
	b el2_unhandled_exception 

// TODO: FIQ handling is currently unimplemented
el2_fiq_entry:
	b el2_unhandled_exception

// TODO: SError handling is currently unimplemented
el2_serror_entry:
	b el2_unhandled_exception


