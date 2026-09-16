```text

FUTURE TODO: Dedicated Exception Handler Stack via SP_EL0

The current exception path builds the exception context frame directly on SP_EL2. This is sufficient while the interrupted stack pointer is immutable 
during exception handling.

When mutable ctx->sp support is introduced, move exception handling onto the dedicated SP_EL0 stack so that the exception frame is independent of the interrupted SP_EL2.

DESIGN:
Exception arrives in EL2h using SP_EL2
        │
        ▼
Capture interrupted SP_EL2
        │
        ▼
SPSel = 0
        │
        ▼
SP_EL0 becomes active handler stack
        │
        ▼
Build exception context frame on SP_EL0
        │
        ▼
C dispatcher operates on ctx
        │
        │
        └── may modify ctx->sp
        │
        ▼
Write ctx->sp → SP_EL2
        │
        ▼
Restore GPRs from exception frame on SP_EL0
        │
        ▼
SPSel = 1
        │
        ▼
ERET
        │
        ▼
Resume EL2 execution using restored SP_EL2


Using SP_EL0 as the exception-handler stack cleanly separates:

the stack containing the exception context, and
the stack pointer of the interrupted EL2 execution.

This removes the dependency between exception-frame allocation and the interrupted SP_EL2, allowing the exception handler to safely modify ctx->sp 
without conflicting with the stack on which the handler itself is executing.
This also makes explicit use of the two stack pointers available at the same exception level:
SP_EL2 for the interrupted EL2 execution and SP_EL0 as the dedicated exception-processing stack.

```
