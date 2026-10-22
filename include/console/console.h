#ifndef AXIOM_CONSOLE_H
#define AXIOM_CONSOLE_H

#ifndef __ASSEMBLER__

void console_init(void);

void console_putc(char c);

void console_puts(const char *s);

#endif

#endif
