#include "console/console.h"

volatile unsigned long test_data = 0x123456789ABCDEF0ULL;

volatile unsigned long test_bss;

unsigned long axiom_read_current_el(void);

void axiom_main(void)
{

	console_init();

	console_puts("Axiom is online now!\n");

	unsigned long el = axiom_read_current_el();

	//volatile unsigned long marker = 0x123456789ABCDEF0UL;
	volatile unsigned long marker = el;

    //while (1) {
    //}
}
