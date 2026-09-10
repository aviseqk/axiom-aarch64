#ifndef AXIOM_PL011_DRIVER_H
#define AXIOM_PL011_DRIVER_H

#include <stdint.h>

// relavant PL011 registers offsets
#define PL011_UARTDR			0x000
#define PL011_UARTFR			0x018
#define PL011_UARTIBRD			0x024
#define PL011_UARTFBRD			0x028
#define PL011_UARTLCR_H			0x02C
#define PL011_UARTCR			0x030


// relavant PL011 register bits
#define PL011_UARTFR_TXFF		(1U << 5) 	// 1: transmit FIFO is full

#define PL011_UARTLCR_H_FEN		(1U << 4)	// 1: FIFO buffers are enabled

#define PL011_UARTLCR_H_WLEN_8		(3U << 5)	// 0b11: word length is 8 bits

#define PL011_UARTCR_TXE		(1U << 8)	// 1: transmit section of UART is enabled

#define PL011_UARTCR_UARTEN		(1U << 0)	// 1: UART is enabled



/* pl011-uart driver layer functions */
void pl011_init(uintptr_t base, uint32_t clk, uint32_t baudrate);

void pl011_putchar(uintptr_t base, char c);

#endif
