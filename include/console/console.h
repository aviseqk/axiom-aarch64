#ifndef AXIOM_CONSOLE_H
#define AXIOM_CONSOLE_H

#ifndef __ASSEMBLER__

#include <stdint.h>

void console_init(void);

void console_putc(char c);

void console_puts(const char *s);

void console_put_hex64(uint64_t value);

#endif

#endif
