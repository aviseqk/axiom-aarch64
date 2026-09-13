/* Axiom's usage of QEMU's memory regions as allocations */

#include "qemu-virt.h"

/* EL3 firmware memory
 * 128KiB firmware allocation
 * NOTE: Axiom is not reserving complete bootROM for its usage at level 1/EL3 
 * */
#define AXIOM_EL3_BOOTROM_BASE		QEMU_FLASH_0_BASE
#define AXIOM_EL3_BOOTROM_SIZE		0x00020000		

/* 64 KiB axiom level 1 el3 runtime ram allocation - comfortable region for axiom level 1 el3 work */
#define AXIOM_EL3_EARLY_SECURE_RAM_BASE	QEMU_SECURE_RAM_BASE
#define AXIOM_EL3_EARLY_SECURE_RAM_SIZE	0x00010000	

#define AXIOM_PLATFORM_DRAM_BASE			QEMU_DRAM_BASE
#define AXIOM_PLATFORM_DRAM_SIZE			QEMU_DRAM_SIZE

//TODO: remove later when we actually design Stack, right now just to avoid symbol-unavailability error from linker script
#define AXIOM_STACK_SIZE		0x00004000
#define AXIOM_EL2_STACK_SIZE		0x00004000


/* EL2 firmware memory
 *
 * 4MiB region from DRAM for EL2, for both its code and runtime state
 * */

/*  NOTE: QEMU virt automatically places its generated DTB at the beginning of DRAM (0x4000000) for this boot config.
 *  Axiom, hence temporarily places the pre-positioned EL2 payload at 0x40100000 to avoid collision with DTB region 
 *
 *  HACK: changed AXIOM_EL2_BASE from AXIOM_PLATFORM_DRAM_BASE to QEMU_DTB_REGION_END, will be revisited when EL3 implements its own EL2 image loader
 *  */
#define AXIOM_EL2_BASE		QEMU_VIRT_DTB_LOAD_END	
#define AXIOM_EL2_SIZE		0x00400000

// rest of DRAM left available for future use 
