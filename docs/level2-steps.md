### Important Steps in AArch64 EL2 Initial Boot Flow

#### The goal is to establish an independently linked minimal Non-Secure EL2 execution environment setup and transition into it from EL3's firmware

```text NOT IN SCOPE:

- Having the actual hypervisor payload at EL2
- Having MMU/page-table implementation enabled at EL2
- EL1 Guest or even Preparation
- Memory Isolation

```

#### Design Choice: for initial EL2 Boot Flow 
*Target is Non-Secure EL2, with MMU disabled*

#### Scope for this EL3->EL2 handoff work
```text 
- Complete a minimal EL3 exception handling
- Define the EL2 Execution Environment
- Create the EL2 payload
- Prepare EL3 architecturally for the transition
- Figure the Security State transition properly
- Perform the ERET
- Establish the EL2 runtime and C runtime
- Verify we are actually in EL2
- Install minimal EL2 Exception Vectors
- Do a cross-level EL3-EL2 exception handling and routing check
```

```text High-Level Steps/Milestones for this level to achieve, before jumping to enabling MMU and making EL2 hypervisor-capable
Axis 1:
- change the placeholder EL3 exception mechanism into a minimal but functional EL3 exception handling mechanism
- test and check up a real EL3 exception, meaning EL3 executes something, and faults and is serviced as per our exception mechanism

Axis 2:
- carve up DRAM and prepare EL2 physical memory allocation in DRAM
- Create independent EL2 linker layout
- Implement EL2 assembly entrypoint
- Establish EL2 stack and basic C runtime state
- Implement EL2 .data relocation and .bss zeroing
- Implement EL2 exception vector table and VBAR_EL2
- Configure EL3->EL2 transition state (SCR_EL3, SPSR_EL3, ELR_EL3, SP_EL2, SCTLR_EL2, VBAR_EL2)
- Perform controlled ERET from EL3 into non-secure EL2
- Enter EL2 C runtime
- Verify CurrentEL== EL2
- Verify EL2 can use existing PL011 console
- Trigger and verify one EL2-local exception

Final cross-level exception check: 
(This is to be tested when exception mechanism in both EL3 and EL2 are setup)
that a deliberate exception or trap starting from EL2 routes itself via EL2 back to EL3 right, for example, an SMC call in real cases

```

