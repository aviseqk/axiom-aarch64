#include <stdint.h>

#include "console/console.h"

int64_t el2_test_bss;
uint64_t el2_test_data = 0x12345678;

void el2_main(void)
{
	console_init();

	console_puts("[EL2]: Axiom C runtime is active\n");
}
