#include "arch/el3.h"

/* Helper macro to load arbitrary values into 64-bit registers which generates the mov/movk combinations. 
because we cannot load a general arbitraty 64 bit constant value using a single instruction in aarch64
movz establishes the initial value and movk replace one 16-bit portion without disturbing the others */
.macro mov_imm reg, value
    movz \reg, ((\value >> 0)  & 0xffff)
    movk \reg, ((\value >> 16) & 0xffff), lsl #16
    movk \reg, ((\value >> 32) & 0xffff), lsl #32
    movk \reg, ((\value >> 48) & 0xffff), lsl #48
.endm

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

1:
	b 1b
