#include "aarch64-arch.h"

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
	- Configure EL3 Control and Configuration State
	- Setup Exception Vectors (VBAR_EL3)
	- Establish memory attributes or MMU - decide whether to do now or later
	- Prepare C runtime
	- branch to first C init function of axiom level 1 firmware
*/
_start:

	// Prepare the EL3 Stack
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
x1             0xc50838            12912696
x2             0x30                48
x3             0x0                 0
x4             0x3c0               960
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

	/* from TF-A as reference, the registers of interest for EL3 Execution Context setup are: 
	(Note that for TF-A's EL3, the assumption is that execution might enter from a different EL and EL3 wants to make sure that whenever it does
	it arrives at a consistent EL3 root context register setup), but the scope of our firmware at this stage is not that mature yet.
	 
	 * DAIF.A: Enable External Aborts and SError Interrupts at EL3. -> NOTE: Our exception infrastructure is very primitive still,
	 it does not have proper handlers for error handling and all, so keep this as a TODO
	 *
	 * MDCR_EL3.SDD: Set to one to disable AArch64 Secure self-hosted debug. Debug exceptions, other than Breakpoint Instruction exceptions, are
	 *  disabled from all ELs in Secure state. -> NOTE: we are actively debugging Axiom using GDB, hence we should not disable secure self-hosted debug
	 and mainly because SDD bit does not matter and is ignored if SCR_EL3.RW is not 0 and we have explicity set that to 1 earlier so yeah
	 *
	 * SCR_EL3.EA: Set to one to enable SError interrupts at EL3. -> NOTE: already setup in CPU architectural state setup step
	 *
	 * SCR_EL3.SIF: Set to one to disable instruction fetches from Non-secure memory.
	 NOTE: not needed yet, first the idea of Secure/Non-Secure Memory is not set in Axiom yet, and also no mechanism for 
	 EL3 -> lower EL hence no case of instruction fetch from Non-Secure memory appears yet.
	 *
	 * PMCR_EL0.DP: Set to one so that the cycle counter, PMCCNTR_EL0 does not count when event counting is prohibited. 
	 Necessary on PMUv3 <= p7 where MDCR_EL3.{SCCD,MCCD} are not available. NOTE: feature not being considered right now
	 *
	 * CPTR_EL3.EZ: Set to one so that accesses to ZCR_EL3 do not trap -> NOTE: we follow the same policy
	 * CPTR_EL3.TFP: Set to one so that accesses to SIMD trap -> 
	   NOTE: for the SIMD/FP exceptions trap, TF-A is trapping but I am doing the opposite, since Axiom, my firmware is an 
	 educational execution environment, I have no reason to trap the SIMD/FP instructions in EL3 in case any C code uses it,
	 so set as 0
	 * CPTR_EL3.ESM: Set to one so that SME related registers don't trap -> NOTE: we follow the same policy
	 * CPTR_EL3.EC: Set to one when Morello is enabled so that access to morello architecture and registers are not trapped -> NOTE: feature irrelavant to us
	 *
	 * PSTATE.DIT: Set to one to enable the Data Independent Timing (DIT) functionality, if implemented in EL3.
	 -> NOTE: Axiom doesn't currently need performance-monitoring semantics or constant-time/data-independent timing behavior so dont set
	*/

	/* TL:DR; for CPTR_EL3 register that controls trapping to EL3 for accesses of different instructions types, 
	we have no reason to trap them, hence Axiom is not using EL3 trapping as a mechanism to prohibit these
	instruction classes at all - for CPTR_EL3.EZ = 1, CPTR_EL3.TFP = 0, CPTR_EL3.ESM = 1*/


	mrs x0, cptr_el3
	orr x0, x0, #CPTR_EZ_BIT
	orr x0, x0, #CPTR_ESM_BIT
	bic x0, x0, #CPTR_TFP_BIT
	msr cptr_el3, x0
	isb

	mrs x0, spsel
	mrs x1, cptr_el3
	mrs x2, scr_el3
	mrs x3, daif
	/* explicitly set the spsel to be 1 to choose SP_EL3 but qemu currently by default does that.
	NOTE: if want to explicity set it to 1, add the following instructions and post that add the __stack_top assignment to sp register 
	msr spsel, #1
	isb
	ldr x0, =__stack_top
	mov sp, x0*/

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

1:
	b 1b
