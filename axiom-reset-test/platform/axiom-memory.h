/* Axiom's usage of QEMU's memory regions as allocations */

#include "qemu-virt.h"

#define AXIOM_BOOTROM_BASE		QEMU_FLASH_0_BASE
#define AXIOM_BOOTROM_SIZE		0x00020000		/* 128KiB firmware allocation - axiom is not reserving complete bootROM for its usage at level 1 */

#define AXIOM_EARLY_SECURE_RAM_BASE	QEMU_SECURE_RAM_BASE
#define AXIOM_EARLY_SECURE_RAM_SIZE	0x00010000		/* 64 KiB axiom level 1 el3 runtime ram allocation - comfortable region for axiom level 1 el3 work */

#define AXIOM_DRAM_BASE			QEMU_DRAM_BASE
#define AXIOM_DRAM_SIZE			QEMU_DRAM_SIZE

//TODO: remove later when we actually design Stack, right now just to avoid symbol-unavailability error from linker script
#define AXIOM_STACK_SIZE		0x00004000
