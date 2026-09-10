/* Basic Console abstraction code */

#include "console/console.h"
#include "platform/qemu-virt.h"
#include "drivers/pl011-uart.h"

void console_init(void)
{
	pl011_init(QEMU_UART_BASE, QEMU_UART_CLOCK_HZ, QEMU_UART_BAUD_RATE);
}

void console_putc(char c)
{
	pl011_putchar(QEMU_UART_BASE, c);
}

void console_puts(const char *s)
{
	while (*s) {
		console_putc(*s++);
	}
}
