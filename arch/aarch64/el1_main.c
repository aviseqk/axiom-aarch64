#include <stdint.h>

#include "console/console.h"

int64_t el1_test_bss;
uint64_t el1_test_data = 0x12345678;

void el1_main(void)
{
	console_init();

	console_puts("[EL1]: Axiom C runtime is active\n");
}
