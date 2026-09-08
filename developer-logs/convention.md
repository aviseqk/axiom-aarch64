# Developer Journal Convention

## Developer Journal - This self-written journal is to keep a persistent trace of evolution of technical reasoning, questions, investigations, decisions, experiments, and solutions made throughout development, with the idea of cross-referencing with these logs
## when the scope becomes wide, because of the intertwined nature of this project.

Each journal entry begins with a small metadata line describing the context in which the said note was written

> **Pattern**: `[ID] · TIME · PHASE · INTENT · ASPECT · STATUS · REF` 

- **ID** — Unique journal entry identifier, e.g. `LOG-014`.
- **TIME** — Date/time when the note was written.
- **PHASE** — Current stage of the project the note belongs to.
- **INTENT** — Why the note was written (question, decision, observation, etc.).
- **ASPECT** — Specific technical subject being discussed.
- **STATUS** — Current state of the thought, question, or decision.
- **REF** - Links this entry to an earlier entry/question/thought log that caused or invoked this question

Example:

> *[LOG-014] · 2026-09-03 22:15 · Boot/Reset · Question · Initial PC · OPEN*


## PHASE

The current stage of development the note belongs to.

- Planning
- Boot / Reset
- EL3 Bring-up
- EL3 → EL2 Transition
- EL2 Hypervisor
- Memory Management
- Exception Handling
- Interrupts
- EL1 Guest
- Context Switching
- CPU / SMP
- SMC / Firmware Interface
- Device / MMIO
- Debugging
- Validation / Testing
- Optimization
- Integration

---

## INTENT

Why the note was written.

- Observation
- Question
- Investigation
- Hypothesis
- Design
- Decision
- Experiment
- Result
- Problem
- TODO
- Reference
- State Snapshot

---

## ASPECT

The specific technical subject being discussed.
This is intentionally free-form and descriptive in nature.

Examples:

- QEMU reset behavior
- Initial PC
- Reset vector
- Stack initialization
- MMU configuration
- Exception vectors
- SPSR_EL2
- HCR_EL2
- EL3 → EL2 transition
- Guest entry
- vCPU state
- SMP bring-up
- CPU context switching
- GIC
- MMIO

---

## STATUS

The current state of the thought, question, experiment, or decision.

- OPEN — Not yet resolved.
- ACTIVE — Currently being worked on.
- BLOCKED — Waiting on something else.
- DECIDED — A decision has been made.
- VALIDATED — Confirmed through testing or evidence.
- SUPERSEDED — Replaced by a later decision or understanding.

## REFERENCES

Journal entries may reference earlier entries to preserve the chain of
reasoning between questions, investigations, decisions, and results.

Common relationships:

- `RESOLVES: [LOG-XXX]`
    This entry answers or closes an earlier question/problem.

- `FOLLOWS: [LOG-XXX]`
    This entry directly continues work from an earlier entry.

- `SUPERSEDES: [LOG-XXX]`
    This entry replaces an earlier decision or understanding.

- `RELATED: [LOG-XXX]`
    This entry is relevant to another entry but does not directly resolve it.

If there is no meaningful relationship, the reference may be omitted.

---

## Examples

> *[LOG-014] · 2026-09-03 22:15 · Boot / Reset · Question · Initial PC · OPEN*

Where exactly does the QEMU virtual CPU begin execution after reset?

---

> *[LOG-027] · 2026-09-06 10:20 · Boot / Reset · Result · Initial PC · VALIDATED · RESOLVES: [LOG-007]*

Confirmed the reset entry point and corresponding memory location.

---

> *[LOG-031] · 2026-09-07 01:12 · EL3 → EL2 Transition · Decision · SPSR_EL2 · DECIDED · FOLLOWS: [LOG-018]*

Axiom will configure the initial EL2 execution state using...



