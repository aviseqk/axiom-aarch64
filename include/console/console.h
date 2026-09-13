#ifndef axiom_console_h
#define axiom_console_h

#ifndef __ASSEMBLER__

void console_init(void);

void console_putc(char c);

void console_puts(const char *s);

#endif

#endif
