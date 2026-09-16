### Important Steps in AArch64 Runtime and Execution Environment Setup

```text EL2 Runtime/Architectural Environment

Steps & Checkpoints:
- EL2 entrypoint baseline - confirm entry through eret into EL2h, and verify initial EL2 execution assumptions like CurrentEL, SPSR, SP_EL2, etc
- EL2 stack - EL2 stack was defined and assigned in EL2, but check if any other setup is needed while in EL2 runtime settings too.
- EL2 architectural control state - Decide, and configure EL2 control registers like SCTLR_EL2, HCR_EL2, etc
- Decide on the hypervisor behaviour, we have to introduce that, but is it okay to introduce that before MMU is enabled and no EL1 transition or what?
- EL2 execution-state configuration: CPTR_EL2, MDCR_EL2 policy, DAIF interrupt mask policy, spsel etc
- EL2 exception-vector infra: define a real exception vector table, establish in VBAR_EL2, and check the handler path
- EL2 exception path validation: trigger a synchronous exception, and verify return/exception behaviour, and later extend it for cross-level exception, interrupts, SErrors, etc
- EL2 runtime memory layout - It is defined already but check if any revision is needed or redecided.
- EL2 runtime .data and .bss initialization
- EL2 C runtime entry
- EL2 console and logging check

FINAL CHECK:
Verify the architectural sanity and intentational EL2 state achieved after all these states configuration, and verify exception handling, C runtime,
and memory init, etc all works.

CROSS-LEVEL FINAL CHECK:
Check exception being routed to EL3 for a exception type like SMC, where the exception should travel to EL3. This will require changes in EL3 
exception infra too, and EL3's runtime but do that together with EL2's invocation side and EL3's side handling side of the mechanism.

NOT ADDRESSING HERE:
MMU, virtual memory or Stage 1-translation are not being covered right now, and also probably hypervisor support as that depends on MMU in best case.
```


