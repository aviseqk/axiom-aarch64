#include <stdint.h>
#include "platform/axiom-memory.h"
#include "arch/mmu/el2.h"

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
#define EL2_TABLE __attribute__((aligned(EL2_TABLE_ALIGN), section(".translation_tables")))

EL2_TABLE uint64_t el2_l0[EL2_TABLE_ENTRIES];
EL2_TABLE uint64_t el2_l1[EL2_TABLE_ENTRIES];

EL2_TABLE uint64_t el2_l2_uart[EL2_TABLE_ENTRIES];
EL2_TABLE uint64_t el2_l2_ram[EL2_TABLE_ENTRIES];

EL2_TABLE uint64_t el2_l3_uart[EL2_TABLE_ENTRIES];
EL2_TABLE uint64_t el2_l3_ram0[EL2_TABLE_ENTRIES];
EL2_TABLE uint64_t el2_l3_ram1[EL2_TABLE_ENTRIES];
EL2_TABLE uint64_t el2_l3_ram2[EL2_TABLE_ENTRIES];


// TODO: these are just shadow descriptor creator to make the tran table entries table, page descriptors etc , they all need logic for permissions, attributes setting, etc
static inline uint64_t make_table_desc(uint64_t table_pa)
{
	return table_pa | 0x3ULL;
}

static inline uint64_t make_block_desc(uint64_t block_pa)
{
	return block_pa | 0x1ULL;
}

static inline uint64_t make_page_desc(uint64_t page_pa)
{
	return page_pa | 0x3ULL;
}

void el2_build_translation_tables(void)
{
	/* clear-zero all the eight tables */
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

	el2_l0[0] = make_table_desc((uint64_t)el2_l1);

	el2_l1[0] = make_table_desc((uint64_t)el2_l2_uart);
	el2_l1[1] = make_table_desc((uint64_t)el2_l2_ram);

	/* UART L2 index - 72 */
	el2_l2_uart[72] = make_table_desc((uint64_t)el2_l3_uart);

	/* populate the UART L3 table */
	el2_l3_uart[0] = make_page_desc(UART_BASE);

	/* RAM L3 index - 0, 1, 2 */
	el2_l2_ram[0] = make_table_desc((uint64_t)el2_l3_ram0);
	el2_l2_ram[1] = make_table_desc((uint64_t)el2_l3_ram1);
	el2_l2_ram[2] = make_table_desc((uint64_t)el2_l3_ram2);

	

	/* populate EL2 RAM, the three L3 tables */

	/* 0x4010_0000 - 0x401F_FFFF => 1st L3 table - from idx 256 to 512 in el2_l3_ram0 table */
	for (uint64_t i = 0; i < 256; ++i) {
		uint64_t pa = EL2_RAM_L3_0_BASE + (i * 0x1000ULL);

		el2_l3_ram0[256 + i] = make_page_desc(pa);
	}

	/* 0x4020_0000 - 0x403F_FFFF => 2nd L3 table - from idx 0 to 512 in el2_l3_ram1 table */
	for (uint64_t i = 0; i < 512; ++i) {
		uint64_t pa = EL2_RAM_L3_1_BASE + (i * 0x1000ULL);

		el2_l3_ram1[i] = make_page_desc(pa);
	}

	/* 0x4040_0000 - 0x405F_FFFF => 3rd L3 table - from idx 0 to 512 in el2_l3_ram2 table */
	for (uint64_t i = 0; i < 256; ++i) {
		uint64_t pa = EL2_RAM_L3_2_BASE + (i * 0x1000ULL);

		el2_l3_ram2[i] = make_page_desc(pa);
	}
}
