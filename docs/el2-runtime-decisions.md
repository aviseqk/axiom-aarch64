### Post entering EL2 from EL3's bootstrap and eret, these are the observations and decisions for the EL2 runtime state and environment.

```text OBSERVATIONS:

The state of EL2 CPU registers just after EL2 was eret into from EL3 are:

(gdb) info registers x0 x1 x2 x3 x4 x5 x6 x7
CurrentEL       x0             0x8                 8
SCTLR_EL2       x1             0x30c50838          818219064
VBAR_EL2        x2             0x40100800          1074792448
SP              x3             0x40105060          1074810976
SPSel           x4             0x1                 1
HCR_EL2         x5             0x0                 0
CPTR_EL2        x6             0x0                 0
MDCR_EL2        x7             0x6                 6
DAIF            x8             0x3c0               960


Conclusions:
1. CurrentEL is 0x8, meaning we have entered into EL2 properly, so that's verified.

2. SCTLR_EL2, by courtesy of EL3, EL2 enters with MMU, instruction and data caches off. We want this exact behaviour for now, so we do not need
to rewrite the SCTLR_EL2 right now, later when we read the D/I cache or MMU step, we will reconfigure this EL2 control register

3. VBAR_EL2, is also installed by the EL3 bootstrap mechanism, the vector base is installed, later while working with exception handler, we will
enhance on this step

4. SP and SPSel, both on entry are correct, EL3 has made sure that the EL2 stack is configured on entry, so we donot need this step either

5. HCR_EL2, this register is for hypervisor-specific behaviour, and we are not configuring that yet, so we leave it as is.
Axiom does not currently enable EL2 virtualization/trapping behavior.
HCR_EL2 remains at its reset baseline until lower-EL execution and virtualization requirements are introduced.

6. CPTR_EL2 and MDCR_EL2 are also at their reset architectural baseline, and we go ahead with them for now. As time goes on, and when we need to 
introduce specific behaviours in EL2, then we will reprogram this register.

CPTR_EL2 is generally needed for trapping FP/SIMD operations from lower-levels and that functionality is not setup in EL2 yet,

and MDCR_EL2 contains debug/PMU/tracing related controls, hence both are part of advanced setup not basic EL2 environment setup.

7. DAIF, in EL2, is 0x3c0, meaning all DAIF bits set 1: before ERET, in EL3 we programmed SPSR_EL3 to be of following policy:
D = 1 = Debug Exceptions Masked
A = 1 = SError masked
I = 1 = IRQ masked
F = 1 = FIQ masked

and we see the same in EL2's DAIF setting when we read them, so for now it follows the basic firmware policy of all interrupts and exceptions masked.

```
