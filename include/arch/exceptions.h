#ifndef AARCH64_EXCEPTIONS_H
#define AARCH64_EXCEPTIONS_H


/* Common Constants to indicate the type of exceptions being entered */

#define SYNC_EXCEPTION_SP0	0x0
#define IRQ_SP0			0x1
#define FIQ_SP0			0x2
#define SERROR_SP0		0x3
#define SYNC_EXCEPTION_SPX	0x4
#define IRQ_SPX			0x5
#define FIQ_SPX			0x6
#define SERROR_SPX		0x7
#define SYNC_EXCEPTION_AARCH64	0x8
#define IRQ_AARCH64		0x9
#define FIQ_AARCH64		0xa
#define SERROR_AARCH64		0xb
#define SYNC_EXCEPTION_AARCH32	0xc
#define IRQ_AARCH32		0xd
#define FIQ_AARCH32		0xe
#define SERROR_AARCH32		0xf

#ifndef __ASSEMBLER__

#include <stdint.h>

struct axiom_exception_context {
    uint64_t x[31];

    uint64_t sp;

    uint64_t elr;
    uint64_t spsr;

    uint64_t esr;
    uint64_t far;
};

void axiom_exception_dispatch(struct axiom_exception_context *ctx);

#endif

#endif

