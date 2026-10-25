#include "arch/mmu/el2_tests.h"

#define TEST_ALIAS_VA  0x403F0000ULL
#define TEST_ALIAS_PA  0x40400000ULL

static void el2_mmu_test_va_pa_alias(void)
{
	// NOTE: the address selected for test is VA: 0x403F0000, PA: 0x40400000
	// this needs the L3 mapping at the said VA to be of the mentioned PA
	
	console_puts("[MMU TEST]: EL2: VA->PA alias\n");

	int ret = el2_map_page(TEST_ALIAS_VA, TEST_ALIAS_PA, EL2_MEM_NORMAL, EL2_MEM_RW, false, true);

	if (ret != 0) {
		console_puts("[MMU TEST]: map failed\n");
		return;
	}

	volatile uint64_t *ptr = (volatile uint64_t *)TEST_ALIAS_VA;

	*ptr = 0xAABBCCDD;

	uint32_t value = *ptr;	// C should simply load the value from the address 0x403F0000

	if (value == 0xAABBCCDD)
		console_puts("[MMU TEST]: PASS\n");
	else
		console_puts("[MMU TEST]: FAIL\n");
}


void el2_mmu_run_tests(void)
{
	console_puts("[MMU TEST]: EL2: begin\n");

	el2_mmu_test_va_pa_alias();

	console_puts("[MMU TEST]: EL2: end\n");
}
