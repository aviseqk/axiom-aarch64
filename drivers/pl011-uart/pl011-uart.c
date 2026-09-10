#include <stdint.h>

#include "mmio/mmio.h"
#include "drivers/pl011-uart.h"

/* internal function for my driver to calculate the baudrate and then assign it to the hardware */
static void pl011_set_baudrate(uintptr_t base, 
		uint32_t clk, uint32_t baudrate)
{
	uint32_t brd_denom = 16 * baudrate;

	uint32_t ibrd = clk / brd_denom;
	uint32_t rem = clk % brd_denom;
	
	uint32_t fbrd = ((rem * 64) + (brd_denom / 2U)) / brd_denom;	// integer division instead of rounding

	mmio_write32(base + PL011_UARTIBRD, ibrd);
	mmio_write32(base + PL011_UARTFBRD, fbrd);
}

/* Peripheral-recommended programming sequence for programming control registers: 
 *
 * Source: ARM AMBA PL011 UART TRM 
 *
 * 1. Disable the UART
 * 2. Wait for current transmission/reception to end
 * 3. Flush the transmit TX FIFO by setting FEN bit to 0 in UARTLCR_H register
 * 4. Reprogram the UARTCR register
 * 5. Enable the UART
 *
 * */
void pl011_init(uintptr_t base, uint32_t clk, uint32_t baudrate)
{
	mmio_write32(base + PL011_UARTCR, 0);	// disable the UART

	pl011_set_baudrate(base, clk, baudrate);	// configure baud rate

	// configure uart settings
	mmio_write32(base + PL011_UARTLCR_H,
			PL011_UARTLCR_H_WLEN_8 | PL011_UARTLCR_H_FEN);

	// enable the UART and TX 
	mmio_write32(base + PL011_UARTCR,
			PL011_UARTCR_UARTEN | PL011_UARTCR_TXE);	
}






void pl011_putchar(uintptr_t base, char c)
{
	// wait/keep polling while the Transmit FIFO is full, i.e. TXFF bit is set
	while (mmio_read32(base + PL011_UARTFR) & PL011_UARTFR_TXFF)
	{}

	mmio_write32(base + PL011_UARTDR, (uint32_t)c);
}
