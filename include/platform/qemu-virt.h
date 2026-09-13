/* QEMU virt machine hardware facts about underlying physical memory */

#ifndef AXIOM_PLATFORM_QEMU_VIRT_H
#define AXIOM_PLATFORM_QEMU_VIRT_H

/* Flash0 - 64MiB - virt.flash0 device in QEMU */
#define QEMU_FLASH_0_BASE			0x00000000
#define QEMU_FLASH_0_SIZE			0x04000000

/* Flash1 - 64MiB - virt.flash1 device in QEMU */
#define QEMU_FLASH_1_BASE			0x04000000
#define QEMU_FLASH_1_SIZE			0x04000000

/* Secure RAM - 16MiB - virt.secure-ram in QEMU */
#define QEMU_SECURE_RAM_BASE			0x0E000000
#define QEMU_SECURE_RAM_SIZE			0x01000000

/* DRAM - 128MiB - mach-virt.ram in QEMU */
#define QEMU_DRAM_BASE				0x40000000
#define QEMU_DRAM_SIZE				0x08000000


// ISSUE: there is a memory region blocked by QEMU for its dtb load when baremetal images are loaded, so acccounting for that TODO: resolve this
#define QEMU_VIRT_DTB_LOAD_BASE		0x40000000
#define QEMU_VIRT_DTB_LOAD_END			0x40100000


#define QEMU_GIC_BASE				0x08000000

#define QEMU_UART_BASE				0x09000000UL	/* pl011 */
#define QEMU_UART_CLOCK_HZ			24000000U	/* QEMU virt's PL011 is connected to a fixed 24MHz clock as documented in the machine's dts */
#define QEMU_UART_BAUD_RATE			115200U

#endif
