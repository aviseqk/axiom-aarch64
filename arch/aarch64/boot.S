#include "arch/el3.h"
#include "arch/el2.h"
#include "el2-build-layout.h"

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
first_early_boot_msg:
    .asciz "[AXIOM] : [EL3]: _start being called\n"

.section .text.boot
.globl _start
.type _start, %function

/*
Initial Firmware Init Sequence
	- Initialize EL3 Stack
	- Configure a known EL3 CPU architectural State
	- Setup Exception Vectors (VBAR_EL3)
	- Configure EL3 Control and Configuration State
	- Prepare EL3 Execution Environment
	- Prepare C runtime
	- branch to first C init function of axiom level 1 firmware w flat addressing
	- Establish memory attributes or MMU
	- branch to first C init function of axiom level 1 firmware w virtual addressing
*/

_start:

	// prepare the EL3 stack
	ldr x0, =__stack_top
	mov sp, x0
	
	// TODO: maybe remove or keep, but this is a small test to check console function i.e. C functions being called from ASM source
	bl console_init		// NOTE: we discovered that a basic running UART support is there even though we dont do console_init, console_putc was transmitting data onto the UART

	ldr x0, =first_early_boot_msg
	bl console_puts
	
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

	/* 
	NOTE: The approach we are taking are, get the established architectural reset value from ARM ARM doc as the baseline,
	and modify the fields/bits we intentionally own right now and write the result back.
	We could have read the current register state that QEMU boot provided us and use that as baseline for applying our changes,
	but I decided on the architectural state value instead.
	*/

	// initialising and establishing registers that we need at this stage of axiom firmware - SCR_EL3, SCTLR_EL3, DAIF

	// setting up SCTLR_EL3 register
	mov_imm x0, (SCTLR_EL3_RESET_VAL & ~(SCTLR_EE_BIT | SCTLR_WXN_BIT \
				| SCTLR_I_BIT | SCTLR_NAA_BIT | SCTLR_C_BIT \
				| SCTLR_A_BIT | SCTLR_M_BIT))
	orr x0, x0, #SCTLR_SA_BIT
	msr SCTLR_EL3, x0
	isb


	// setting up SCR_EL3 register
	mov_imm x0, (SCR_EL3_RESET_VAL & ~(SCR_NSE_BIT | SCR_EEL2_BIT \
				| SCR_HCE_BIT | SCR_SMD_BIT | SCR_FIQ_BIT \
				| SCR_IRQ_BIT | SCR_NS_BIT ))
	orr x0, x0, #SCR_RW_BIT
	orr x0, x0, #SCR_EA_BIT
	msr SCR_EL3, x0
	isb


	// setting up DAIF register - keeping exceptions masked during early initialization
	msr daifset, #0xf
	isb

	// now the desired EL3 CPU Control State is set, and next step is establishing EL3's own execution environment. This 
	// step is congruent to what BL1 in TF-A does via setup_el3_execution_context macro in bl1_entrypoint path. 
	// and this is needed, because whenever code runs at EL3, and in Root Context, there are few EL3 registers that need be
	// configured while any code runs at EL3

	/* 
	* now the desired EL3 CPU Control State is set, and next step is establishing EL3's own execution environment. 
	*
	* This step is congruent to what BL1 in TF-A does via setup_el3_execution_context macro in bl1_entrypoint path. 
	* and this is needed, because whenever code runs at EL3, and in Root Context, there are few EL3 registers that need be
	* configured while any code runs at EL3
	*
	* The architectural policy of my decisions and reference against TF-A BL1's decisions for the EL3 execution
	* environment configuration is documented in:
	* docs/el3-execution-environment-decisions.md
	*/

	mrs x0, cptr_el3
	orr x0, x0, #CPTR_EZ_BIT
	orr x0, x0, #CPTR_ESM_BIT
	bic x0, x0, #CPTR_TFP_BIT
	msr cptr_el3, x0
	isb

	/* explicitly set the spsel to be 1 to choose SP_EL3 but qemu currently by default does that.
	* NOTE: if want to explicity set it to 1, add the following instructions and post that add the __stack_top assignment to sp register 
	msr spsel, #1
	isb
	ldr x0, =__stack_top
	mov sp, x0
	*/

	// copy .data from its load address in BOOTROM to its runtime address in SECURE_RAM
	ldr x0, =__data_load
	ldr x1, =__data_start
	ldr x2, =__data_end

copy_data_to_runtime:
	cmp x1, x2
	b.hs zero_bss_prep

	ldr x3, [x0], #8
	str x3, [x1], #8

	b copy_data_to_runtime

// zero bss section of SECURE_RAM by using linker-provided symbols
zero_bss_prep:
	ldr x0, =__bss_start
	ldr x1, =__bss_end

zero_bss:
	cmp x0, x1
	b.hs end_zero_bss

	str xzr, [x0], #8

	b zero_bss

end_zero_bss:
	bl axiom_main

	bl axiom_enter_el2

1:	
	b 1b

/* prepare the exception return and context for CPU to jump to EL2 and do ERET */
axiom_enter_el2:
	// prepare EL2's stack
	ldr x0, =AXIOM_EL2_STACK_TOP
	msr SP_EL2, x0

	// program the SCR_EL3, configuring the execution environment at lower EL
	mrs x0, SCR_EL3
	orr x0, x0, #SCR_NS_BIT
	orr x0, x0, #SCR_HCE_BIT
	msr SCR_EL3, x0
	isb

	// program the EL2's execution environment i.e. SCTLR_EL2
	mov_imm x0, (SCTLR_EL2_RESET_VAL & ~(SCTLR_EE_BIT | SCTLR_WXN_BIT \
			| SCTLR_I_BIT | SCTLR_NAA_BIT | SCTLR_C_BIT \
			| SCTLR_A_BIT | SCTLR_M_BIT))
	orr x0, x0, #SCTLR_SA_BIT
	msr SCTLR_EL2, x0
	isb

	// prepare the EL2 return state, SPSR_EL3
	mov_imm x0, SPSR_EL3_M_EL2h

	orr x0, x0, #SPSR_EL3_D_BIT
	orr x0, x0, #SPSR_EL3_A_BIT
	orr x0, x0, #SPSR_EL3_I_BIT
	orr x0, x0, #SPSR_EL3_F_BIT

	msr SPSR_EL3, x0

	// setup VBAR_EL2 for EL2
	ldr x0, =AXIOM_EL2_VECTOR_BASE
	msr VBAR_EL2, x0
	isb

	// assign the entrypoint address of EL2
	ldr x0, =AXIOM_EL2_ENTRY
	msr ELR_EL3, x0

	// Transition
	eret
