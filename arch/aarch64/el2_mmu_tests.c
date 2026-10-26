#include "arch/mmu/el2_tests.h"

#define TEST_ALIAS_VA  0x403F0000ULL
#define TEST_ALIAS_PA  0x40400000ULL

#define TEST_RO_VA  0x403E0000UL
#define TEST_RO_PA  0x40410000UL

#define TEST_XN_VA  0x403D0000UL
#define TEST_XN_PA  0x40411000UL

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

/* This test should FAULT with Translation Level 3 Fault as the desc is missing for the unmapped page */
static void el2_mmu_test_unmapped_read(void)
{
	console_puts("[MMU TEST]: EL2: Unmapped Read\n");

	volatile uint64_t value = *(volatile uint64_t *)0x40400000;

	(void)value;
}

/* This test attempts to write in a mapped read-only page, should FAULT with Permission Level 3 Fault */
static void el2_mmu_test_read_only_write(void)
{
	console_puts("[MMU TEST]: EL2: Write in Read-Only\n");

	int ret = el2_map_page(TEST_RO_VA, TEST_RO_PA, EL2_MEM_NORMAL, EL2_MEM_RO, false, true);
	if (ret != 0)
		console_puts("[MMU TEST]: map failed\n");

	*(volatile uint64_t *)TEST_RO_VA = 0x1234ABCDULL;
}

static void el2_mmu_prepare_xn_page(void)
{
	volatile uint32_t *code = (volatile uint32_t *)TEST_XN_VA;

	code[0] = 0xD2800000;  // mov x0, #0
	code[1] = 0xD65F03C0;  // ret

	__asm__ volatile("dsb sy" ::: "memory");
	__asm__ volatile("isb");
}

/* This test attempts to execute an instruction placed in a XN region by branching to it */
static void el2_mmu_test_execute_xn_region(void)
{
	console_puts("[MMU TEST]: EL2: Execute from XN region\n");

	/* I first establish the VA->PA mapping as RW XN so that i can put instructions as code there */
	int ret = el2_map_page(TEST_XN_VA, TEST_XN_PA, EL2_MEM_NORMAL, EL2_MEM_RW, false, true);
	if (ret != 0)
		console_puts("[MMU TEST]: map failed\n");

	el2_mmu_prepare_xn_page();

	void (*test_fn)(void) = (void (*)(void))TEST_XN_VA;

	test_fn();

	console_puts("[MMU TEST]: XN execution returned - SHOULD NOT HAVE\n");
}

void el2_mmu_run_tests(void)
{
	console_puts("[MMU TEST]: EL2: begin\n");

	//el2_mmu_test_va_pa_alias();
	//el2_mmu_test_unmapped_read();
	//el2_mmu_test_read_only_write();
	//el2_mmu_test_execute_xn_region();

	console_puts("[MMU TEST]: EL2: end\n");
}
