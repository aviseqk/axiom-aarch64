#include "arch/exceptions.h"

.section .rodata
el1_sync_exception_log:
	.asciz "[EL1]: synchronous exception\n"


.section .vectors, "ax"
.align 11
.globl el1_vector_table

el1_vector_table:

	// Current EL with SP0
	mov x0, #SYNC_EXCEPTION_SP0
	b el1_sync_entry	// Synchronous Exceptions
	.space 0x78
	mov x0, #IRQ_SP0
	b el1_irq_entry		// IRQs
	.space 0x78
	mov x0, #FIQ_SP0
	b el1_fiq_entry		// FIQs
	.space 0x78
	mov x0, #SERROR_SP0
	b el1_serror_entry	// SErrors	
	.space 0x78


	// Current EL with SPx
	mov x0, #SYNC_EXCEPTION_SPX
	b el1_sync_entry	
	.space 0x78
	mov x0, #IRQ_SPX
	b el1_irq_entry
	.space 0x78
	mov x0, #FIQ_SPX
	b el1_fiq_entry
	.space 0x78
	mov x0, #SERROR_SPX
	b el1_serror_entry
	.space 0x78


	// Lower EL using AArch64
	mov x0, #SYNC_EXCEPTION_AARCH64
	b el1_sync_entry
	.space 0x78
	mov x0, #IRQ_AARCH64
	b el1_irq_entry
	.space 0x78
	mov x0, #FIQ_AARCH64
	b el1_fiq_entry
	.space 0x78
	mov x0, #SERROR_AARCH64
	b el1_serror_entry
	.space 0x78
	

	// Lower EL using AArch32
	mov x0, #SYNC_EXCEPTION_AARCH32
	b el1_sync_entry
	.space 0x78
	mov x0, #IRQ_AARCH32
	b el1_irq_entry
	.space 0x78
	mov x0, #FIQ_AARCH32
	b el1_fiq_entry
	.space 0x78
	mov x0, #SERROR_AARCH32
	b el1_serror_entry
	.space 0x78

.section .text.exceptions, "ax"


el1_unhandled_exception:
1:
	b 1b

el1_sync_entry:
	ldr x0, =el1_sync_exception_log
	bl console_puts

	b el1_unhandled_exception

el1_irq_entry:
	b el1_unhandled_exception

el1_fiq_entry:
	b el1_unhandled_exception

el1_serror_entry:
	b el1_unhandled_exception
