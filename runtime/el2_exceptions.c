#include "arch/exceptions.h"
#include "console/console.h"

void axiom_exception_dispatch(struct axiom_exception_context *ctx)
{
	console_puts("[EL2]: exception dispatched to C\n");

	ctx->elr += 4;

}

