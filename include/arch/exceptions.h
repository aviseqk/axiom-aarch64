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

#define ESR_EC_SHIFT		26
#define ESR_EC_MASK		0x3f

#define ESR_EC(esr) \
    ((esr >> ESR_EC_SHIFT) & ESR_EC_MASK)

#define ESR_IL_BIT		(1ULL << 25)
#define ESR_ISS_MASK		0x1FFFFFFULL


/* Expection Class values */
#define ESR_EC_UNKNOWN		    0x00
#define ESR_EC_WFI		    0x01
#define ESR_EC_SVC_AARCH64	    0x15
#define ESR_EC_HVC_AARCH64	    0x16
#define ESR_EC_SMC_AARCH64	    0x17
#define ESR_EC_TRAPPED_ERETx	    0x1a
#define ESR_EC_INST_ABORT_LOWER	    0x20
#define ESR_EC_INST_ABORT_CURRENT   0x21
#define ESR_EC_PC_ALIGN_FAULT	    0x22
#define ESR_EC_DATA_ABORT_LOWER	    0x24
#define ESR_EC_DATA_ABORT_CURRENT   0x25
#define ESR_EC_SP_ALIGN_FAULT	    0x26
#define ESR_EC_BRK_AARCH64	    0x3c


/* Data/Instruction Fault Status Code [5:0] bits in ISS section of ESR_EL2 */
#define ESR_FSC_MASK		0x3f
#define ESR_FSC(esr) \
    (esr & ESR_FSC_MASK)

// NOTE: right now only Translation & Permission faults are being monitored
#define ESR_FSC_TRANSLATION_L0	    0x04
#define ESR_FSC_TRANSLATION_L1	    0x05
#define ESR_FSC_TRANSLATION_L2	    0x06
#define ESR_FSC_TRANSLATION_L3	    0x07

#define ESR_FSC_PERMISSION_L0	    0x0c
#define ESR_FSC_PERMISSION_L1	    0x0d
#define ESR_FSC_PERMISSION_L2	    0x0e
#define ESR_FSC_PERMISSION_L3	    0x0f

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

__attribute__((noreturn)) void el2_panic(void);


#endif

#endif

