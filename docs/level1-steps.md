### Important Steps in AArch64 EL3 Boot Flow

```text
CPU reset
│
▼
_start
├── establish SP_EL3
│
├── establish EL3 exception vectors
│
├── establish desired EL3 control state
│   ├── SCR_EL3
│   ├── SCTLR_EL3
│   └── DAIF / masking policy
│
├── establish architectural execution environment
│   ├── stack/alignment assumptions
│   ├── FP/SIMD policy if needed
│   └── other EL3 state needed by Axiom
│
├── establish runtime memory state
│   ├── BSS
│   ├── C runtime stack
│   └── eventually MMU/cache configuration
│
├── enter C runtime
│   └── axiom_main()
│
└── later:
    ├── configure lower ELs
    ├── world/security state
    ├── virtualization state
    └── handoff / EL transition
```
