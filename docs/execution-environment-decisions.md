```text
TL:DR; for CPTR_EL3 register that controls trapping to EL3 for accesses of different instruction types,
we have no reason to trap them, hence Axiom is not using EL3 trapping as a mechanism to prohibit these
instruction classes at all - for CPTR_EL3.EZ = 1, CPTR_EL3.TFP = 0, CPTR_EL3.ESM = 1.
```

```text
From TF-A as reference, the registers of interest for EL3 Execution Context setup are:
(Note that for TF-A's EL3, the assumption is that execution might enter from a different EL and EL3 wants to make sure that whenever it does
it arrives at a consistent EL3 root context register setup), but the scope of our firmware at this stage is not that mature yet.
	 
DAIF.A: Enable External Aborts and SError Interrupts at EL3.
    NOTE: Our exception infrastructure is very primitive still,
    it does not have proper handlers for error handling and all, so keep this as a TODO.
	 
MDCR_EL3.SDD: Set to one to disable AArch64 Secure self-hosted debug. Debug exceptions, other than Breakpoint Instruction exceptions, are
disabled from all ELs in Secure state.
    NOTE: we are actively debugging Axiom using GDB, hence we should not disable secure self-hosted debug
    and mainly because SDD bit does not matter and is ignored if SCR_EL3.RW is not 0 and we have explicity set that to 1 earlier so yeah.
	 
SCR_EL3.EA: Set to one to enable SError interrupts at EL3.
    NOTE: already setup in CPU architectural state setup step.
 
SCR_EL3.SIF: Set to one to disable instruction fetches from Non-secure memory.
    NOTE: not needed yet, first the idea of Secure/Non-Secure Memory is not set in Axiom yet, and also no mechanism for
    EL3 -> lower EL hence no case of instruction fetch from Non-Secure memory appears yet.
	 
PMCR_EL0.DP: Set to one so that the cycle counter, PMCCNTR_EL0 does not count when event counting is prohibited.
Necessary on PMUv3 <= p7 where MDCR_EL3.{SCCD,MCCD} are not available.
    NOTE: feature not being considered right now.
	 
CPTR_EL3.EZ: Set to one so that accesses to ZCR_EL3 do not trap.
    NOTE: we follow the same policy.
	 
CPTR_EL3.TFP: Set to one so that accesses to SIMD trap.
    NOTE: for the SIMD/FP exceptions trap, TF-A is trapping but I am doing the opposite, since Axiom, my firmware is an
    educational execution environment, I have no reason to trap the SIMD/FP instructions in EL3 in case any C code uses it,
    so set as 0.
	 
CPTR_EL3.ESM: Set to one so that SME related registers don't trap.
    NOTE: we follow the same policy.
	 
CPTR_EL3.EC: Set to one when Morello is enabled so that access to morello architecture and registers are not trapped.
    NOTE: feature irrelevant to us.
	 
PSTATE.DIT: Set to one to enable the Data Independent Timing (DIT) functionality, if implemented in EL3.
    NOTE: Axiom doesn't currently need performance-monitoring semantics or constant-time/data-independent timing behavior so don't set.
```

