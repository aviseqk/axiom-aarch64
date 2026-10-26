#include <stdint.h>
#include "arch/exceptions.h"
#include "console/console.h"

static void decode_fault_status(uint64_t esr)
{
	uint64_t fsc = ESR_FSC(esr);

	switch (fsc) {
	case ESR_FSC_TRANSLATION_L0:
		console_puts("[EL2]: FSC = Translation Fault, Level 0\n");
		break;
	case ESR_FSC_TRANSLATION_L1:
		console_puts("[EL2]: FSC = Translation Fault, Level 1\n");
		break;
	case ESR_FSC_TRANSLATION_L2:
		console_puts("[EL2]: FSC = Translation Fault, Level 2\n");
		break;
	case ESR_FSC_TRANSLATION_L3:
		console_puts("[EL2]: FSC = Translation Fault, Level 3\n");
		break;
	case ESR_FSC_PERMISSION_L0:
		console_puts("[EL2]: FSC = Permission Fault, Level 0\n");
		break;
	case ESR_FSC_PERMISSION_L1:
		console_puts("[EL2]: FSC = Permission Fault, Level 1\n");
		break;
	case ESR_FSC_PERMISSION_L2:
		console_puts("[EL2]: FSC = Permission Fault, Level 2\n");
		break;
	case ESR_FSC_PERMISSION_L3:
		console_puts("[EL2]: FSC = Permission Fault, Level 3\n");
		break;
	default:
		console_puts("[EL2]: FSC = Other Data Abort Fault\n");
		break;
	}
}

static void decode_esr(uint64_t esr, uint64_t far, uint64_t elr)
{
	uint64_t ec = ESR_EC(esr);
	
	console_puts("[EL2]: ESR = ");
	console_put_hex64(esr);
	console_puts("\n");
	console_puts("[EL2]: FAR = ");
	console_put_hex64(far);
	console_puts("\n");
	console_puts("[EL2]: ELR = ");
	console_put_hex64(elr);
	console_puts("\n");

	switch (ec) {
		case ESR_EC_DATA_ABORT_CURRENT:
			console_puts("[EL2]: EC = Data Abort - Current Level\n");
			decode_fault_status(esr);
			break;
		case ESR_EC_INST_ABORT_CURRENT:
			console_puts("[EL2]: EC = Instruction Abort - Current Level\n");
			decode_fault_status(esr);
			el2_panic();	// NOTE: i have no way of handling these faults
			break;
		case ESR_EC_SVC_AARCH64:
			console_puts("[EL2]: EC = SVC in AARCH64 State\n");
			break;
		case ESR_EC_HVC_AARCH64:
			console_puts("[EL2]: EC = HVC in AARCH64 State\n");
			break;
		case ESR_EC_SMC_AARCH64:
			console_puts("[EL2]: EC = SMC in AARCH64 State\n");
			break;
		case ESR_EC_UNKNOWN:
			console_puts("[EL2]: EC = Unknown Instruction/Exception\n");
			break;
		default:
			console_puts("[EL2]: EC = other unhandled exception\n");
			break;
	}
}

void axiom_exception_dispatch(struct axiom_exception_context *ctx)
{
	console_puts("[EL2]: exception dispatched to C\n");

	decode_esr(ctx->esr, ctx->far, ctx->elr);
	
	// NOTE: incrementing ELR_ELx by one instruction is not the way to recover from every exception
	// It did work up until now, but it ran into infinite exception loop info specific service
	// cases like page fault due to instruction, data abort, permissions issues etc
	// TODO: replace this with more sophisticated exception recovery mechanism
	ctx->elr += 4;
}

