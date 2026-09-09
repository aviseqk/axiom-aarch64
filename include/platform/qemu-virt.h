/* QEMU virt machine hardware facts about underlying physical memory */

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

#define QEMU_GIC_BASE				0x08000000
#define QEMU_UART_BASE				0x09000000	/* pl011 */
