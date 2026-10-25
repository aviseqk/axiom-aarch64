#include <stdint.h>
#include <stddef.h>
#include "platform/axiom-memory.h"
#include "arch/mmu/el2.h"
#include "console/console.h"

#define EL2_PAGE_SIZE		0x1000ULL
#define EL2_TABLE_ENTRIES	512ULL
#define EL2_TABLE_ALIGN		0x1000ULL

#define EL2_RAM_BASE		AXIOM_EL2_BASE
#define EL2_RAM_SIZE		AXIOM_EL2_SIZE
#define EL2_RAM_END		(AXIOM_EL2_BASE + AXIOM_EL2_SIZE)

#define UART_BASE		QEMU_UART_BASE
#define UART_SIZE		0x1000ULL
#define UART_END		(UART_BASE + UART_SIZE)

// L3 mapping chunks
#define EL2_RAM_L3_0_BASE	EL2_RAM_BASE
#define EL2_RAM_L3_0_END	(EL2_RAM_L3_0_BASE + 0x00100000ULL)

#define EL2_RAM_L3_1_BASE	EL2_RAM_L3_0_END
#define EL2_RAM_L3_1_END	(EL2_RAM_L3_1_BASE + 0x00200000ULL)

#define EL2_RAM_L3_2_BASE	EL2_RAM_L3_1_END
#define EL2_RAM_L3_2_END	EL2_RAM_END


/* as each translation table is exactly 4KiB in size */
/*
 * EL2 RAM has the three static L3 tables 
 * 0x4010_0000 - 0x401F_FFFF => 1st L3 table - from idx 256 to 512 in el2_l3_ram0 table
 * 0x4020_0000 - 0x403F_FFFF => 2nd L3 table - from idx 0 to 512 in el2_l3_ram1 table
 * 0x4040_0000 - 0x405F_FFFF => 3rd L3 table - from idx 0 to 512 in el2_l3_ram2 table
 * */
#define EL2_TABLE __attribute__((aligned(EL2_TABLE_ALIGN), section(".translation_tables")))

EL2_TABLE uint64_t el2_l0[EL2_TABLE_ENTRIES];
EL2_TABLE uint64_t el2_l1[EL2_TABLE_ENTRIES];

EL2_TABLE uint64_t el2_l2_uart[EL2_TABLE_ENTRIES];
EL2_TABLE uint64_t el2_l2_ram[EL2_TABLE_ENTRIES];

EL2_TABLE uint64_t el2_l3_uart[EL2_TABLE_ENTRIES];
EL2_TABLE uint64_t el2_l3_ram0[EL2_TABLE_ENTRIES];
EL2_TABLE uint64_t el2_l3_ram1[EL2_TABLE_ENTRIES];
EL2_TABLE uint64_t el2_l3_ram2[EL2_TABLE_ENTRIES];


// to read already defined linker symbol in C code that stores address
extern char __el2_text_start[];
extern char __el2_text_end[];

extern char __el2_vector_table_start[];
extern char __el2_vector_table_end[];

extern char __el2_rodata_start[];
extern char __el2_rodata_end[];

extern char __el2_data_start[];
extern char __el2_data_end[];
extern char __el2_bss_start[];
extern char __el2_bss_end[];
extern char __el2_stack_bottom[];
extern char __el2_stack_top[];

extern char __el2_translation_tables_start[];
extern char __el2_translation_tables_end[];

__attribute__((noreturn)) void el2_panic(void)
{
	console_puts("[EL2]: PANIC\n");

	for (;;)
		__asm__ volatile("wfi");
}

static inline uint64_t el2_l0_index(uintptr_t va){
	return (va >> 39) & 0x1FF;
}

static inline uint64_t el2_l1_index(uintptr_t va){
	return (va >> 30) & 0x1FF;
}

static inline uint64_t el2_l2_index(uintptr_t va){
	return (va >> 21) & 0x1FF;
}

static inline uint64_t el2_l3_index(uintptr_t va){
	return (va >> 12) & 0x1FF;
}

static inline uint64_t make_page_desc(uint64_t pa,
		uint64_t attr_index, uint64_t ap, uint64_t sh,
		int access_flag, int xn)
{
	uint64_t desc = 0;

	desc |= DESC_VALID;
	desc |= DESC_TYPE_PAGE;

	desc |= pa & DESC_OA_MASK;

	/* MAIR_EL2 attribute index */
	desc |= (attr_index & 0x7ULL) << DESC_ATTRINDX_SHIFT;

	desc |= ap;
	desc |= sh;

	if (access_flag)
		desc |= DESC_AF;

	if (xn)
		desc |= DESC_XN;

	return desc;
}

static uint64_t *el2_get_l3_table(uintptr_t va)
{
	uint64_t l1_index = el2_l1_index(va);
	uint64_t l2_index = el2_l2_index(va);

	if (l1_index == 0) {
		if (l2_index == 72)
			return el2_l3_uart;

		return NULL;
	}

	switch (l2_index) {
		case 0:
			return el2_l3_ram0;
		case 1:
			return el2_l3_ram1;
		case 2:
			return el2_l3_ram2;
		default:
			return NULL;
	}
	return NULL;
}

static void el2_install_l3_page(uintptr_t va, uint64_t desc)
{
	uint64_t *l3;
	uint64_t l3_index;

	l3 = el2_get_l3_table(va);
	if (l3 == NULL)
		el2_panic();

	l3_index = el2_l3_index(va);

	l3[l3_index] = desc;
}

static const struct el2_memory_region el2_regions[] = {
	// .text section
	{
		.start = (uintptr_t)__el2_text_start,
		.end = (uintptr_t)__el2_text_end,
		
		.type = EL2_MEM_NORMAL,
		.perm = EL2_MEM_RO,

		.executable = true,
		.inner_shareable = true,
	},
	// .vectors section
	{
		.start = (uintptr_t)__el2_vector_table_start,
		.end = (uintptr_t)__el2_vector_table_end,
		
		.type = EL2_MEM_NORMAL,
		.perm = EL2_MEM_RO,

		.executable = true,
		.inner_shareable = true,
	},
	// .rodata section
	{
		.start = (uintptr_t)__el2_rodata_start,
		.end = (uintptr_t)__el2_rodata_end,
		
		.type = EL2_MEM_NORMAL,
		.perm = EL2_MEM_RO,

		.executable = false,
		.inner_shareable = true,
	},
	// .data section
	{
		.start = (uintptr_t)__el2_data_start,
		.end = (uintptr_t)__el2_data_end,
		
		.type = EL2_MEM_NORMAL,
		.perm = EL2_MEM_RW,

		.executable = false,
		.inner_shareable = true,
	},
	// .bss section
	{
		.start = (uintptr_t)__el2_bss_start,
		.end = (uintptr_t)__el2_bss_end,
		
		.type = EL2_MEM_NORMAL,
		.perm = EL2_MEM_RW,

		.executable = false,
		.inner_shareable = true,
	},
	// .stack section
	{
		.start = (uintptr_t)__el2_stack_bottom,
		.end = (uintptr_t)__el2_stack_top,
		
		.type = EL2_MEM_NORMAL,
		.perm = EL2_MEM_RW,

		.executable = false,
		.inner_shareable = true,
	},
	// .translation_tables section
	{
		.start = (uintptr_t)__el2_translation_tables_start,
		.end = (uintptr_t)__el2_translation_tables_end,
		
		.type = EL2_MEM_NORMAL,
		.perm = EL2_MEM_RW,

		.executable = false,
		.inner_shareable = true,
	},
	// UART's device memory - not an ELF section
	{
		.start = (uintptr_t)UART_BASE,
		.end = (uintptr_t)UART_END,

		.type = EL2_MEM_DEVICE,
		.perm = EL2_MEM_RW,

		.executable = false,
		.inner_shareable = true,
	},
	// NOTE: The physical page at 0x40400000 exists after adding it as a memory region,
	// and allowing me to explicitly map one VA to it so that alias experiment does not fault on access
	{
		.start = 0x40400000,
		.end = 0x40401000,
		.type = EL2_MEM_NORMAL,
		.perm = EL2_MEM_RW,
		.executable = false,
		.inner_shareable = true,
	},
};

#define EL2_REGION_COUNT \
	(sizeof(el2_regions) / sizeof(el2_regions[0]))

static uint64_t el2_region_to_page_desc(
		const struct el2_memory_region *region,
		uintptr_t pa)
{
	uint64_t attr_index;
	uint64_t ap;
	uint64_t xn;
	uint64_t sh;
	
	switch(region->type) {
	case EL2_MEM_NORMAL:
		attr_index = AXIOM_MAIR_ATTR_NORMAL;
		break;
	case EL2_MEM_DEVICE:
		attr_index = AXIOM_MAIR_ATTR_DEVICE;
		break;
	default:
		return 0;
	}

	switch(region->perm) {
	case EL2_MEM_RO:
		ap = DESC_AP_RO;
		break;
	case EL2_MEM_RW:
		ap = DESC_AP_RW;
		break;
	default:
		return 0;
	}

	xn = !(region->executable);

	sh = region->inner_shareable ? DESC_SH_INNER_SHAREABLE : DESC_SH_NON_SHAREABLE;

	return make_page_desc(pa, attr_index, ap, sh, 1, xn);
}

#define EL2_PAGE_MASK  (EL2_PAGE_SIZE - 1)	// 0x0FFF
static bool is_el2_memory_region_page_aligned(
		const struct el2_memory_region *region)
{
	// TODO: the region->end check will fail because section's _end linker address is not aligned
	return ((region->start & EL2_PAGE_MASK) == 0);
		//&& ((region->end & EL2_PAGE_MASK) == 0);
}

static bool is_el2_memory_region_valid(
		const struct el2_memory_region *region)
{
	if (region->start >= region->end)
		return false;
	if (!is_el2_memory_region_page_aligned(region))
		return false;

	return true;
}

static void el2_map_region(const struct el2_memory_region *region)
{
	uintptr_t va;

	if (!is_el2_memory_region_valid(region))
		el2_panic();

	for (va = region->start; va < region->end; va += EL2_PAGE_SIZE) {
		uint64_t desc;

		// identity mapping
		desc = el2_region_to_page_desc(region, va);

		el2_install_l3_page(va, desc);
	}

}

static inline uint64_t make_table_desc(uint64_t table_pa)
{
	uint64_t desc = 0;

	desc |= DESC_VALID;
	desc |= DESC_TYPE_TABLE;
	
	/* NOTE: since hierarchical AP, XN or other restrictions at upper level, would 
	 * put that restriction on the following subtrees of L1,L0, etc too, 
	 * hence no restrictions being applied at table-level here for now */
	desc |= table_pa & DESC_OA_MASK;

	return desc;
}

static inline uint64_t make_block_desc(uint64_t block_pa)
{
	return block_pa | 0x1ULL;
}

void el2_clear_translation_tables(void)
{
	/* clear-zero all the eight tables - which also makes the descriptors mapping invalid */
	for (uint64_t i = 0; i < 512; ++i) {
		el2_l0[i] = 0;
		el2_l1[i] = 0;

		el2_l2_uart[i] = 0;
		el2_l2_ram[i] = 0;

		el2_l3_uart[i] = 0;
		el2_l3_ram0[i] = 0;
		el2_l3_ram1[i] = 0;
		el2_l3_ram2[i] = 0;
	}
}

void el2_build_table_topology(void)
{
	el2_l0[0] = make_table_desc((uint64_t)el2_l1);

	el2_l1[0] = make_table_desc((uint64_t)el2_l2_uart);
	el2_l1[1] = make_table_desc((uint64_t)el2_l2_ram);

	/* UART L2 index - 72 */
	el2_l2_uart[72] = make_table_desc((uint64_t)el2_l3_uart);

	/* RAM L3 index - 0, 1, 2 */
	el2_l2_ram[0] = make_table_desc((uint64_t)el2_l3_ram0);
	el2_l2_ram[1] = make_table_desc((uint64_t)el2_l3_ram1);
	el2_l2_ram[2] = make_table_desc((uint64_t)el2_l3_ram2);
}

static inline uint64_t make_normal_rw_xn_desc(uint64_t pa)
{
	return make_page_desc(pa, AXIOM_MAIR_ATTR_NORMAL, DESC_AP_RW, DESC_SH_INNER_SHAREABLE, 1, 1);
}

void el2_build_translation_tables(void)
{
	el2_clear_translation_tables();

	el2_build_table_topology();

	for (size_t i = 0; i < EL2_REGION_COUNT; i++){
		el2_map_region(&el2_regions[i]);
	}

	// TODO: for the el2_va_pa_translation alias test, REMOVE post confirmation
	uint64_t desc = make_normal_rw_xn_desc(0x40400000);

	el2_install_l3_page(0x403F0000, desc);

}
