#include <stdint.h>

#include "console/console.h"
#include "arch/mmu/el2.h"

int64_t el2_test_bss;
uint64_t el2_test_data = 0x12345678;

static void el2_test_va_pa_translation(void)
{
	// NOTE: the address selected for test is VA: 0x403F0000, PA: 0x40400000
	// this needs the L3 mapping at the said VA to be of the mentioned PA
	
	volatile uint32_t *pa = (volatile uint32_t *)0x40400000;

	volatile uint32_t *va = (volatile uint32_t *)0x403F0000;

	*pa = 0xAABBCCDD;

	uint32_t value = *va;	// C should simply load the value from the address 0x403F0000

	if (value == 0xAABBCCDD)
		console_puts("[EL2]: VA->PA alias test PASSED\n");
	else
		console_puts("[EL2]: VA->PA alias test FAILED\n");
}

void el2_main(void)
{
	console_init();

	console_puts("[EL2]: Axiom C runtime is active\n");

	el2_build_translation_tables();

	console_puts("[EL2]: translation tables built\n");

	el2_enable_mmu();

	console_puts("[EL2]: MMU enabled\n");

	el2_test_va_pa_translation();

}


