#include <stdio.h>
#include <stddef.h>
#include <stdint.h>

#include "arch/exceptions.h"

struct sysreg {
    const char *name;
    size_t offset;
};

static struct sysreg sysregs[] = {
    {"SP",   offsetof(struct axiom_exception_context, sp)},
    {"ELR",  offsetof(struct axiom_exception_context, elr)},
    {"SPSR", offsetof(struct axiom_exception_context, spsr)},
    {"ESR",  offsetof(struct axiom_exception_context, esr)},
    {"FAR",  offsetof(struct axiom_exception_context, far)},
};

static int sysreg_size = sizeof(sysregs) / sizeof(sysregs[0]);

const char *fname = "include/generated/axiom-exception-ctx-offset.h";

void extract_axiom_exception_offset(FILE *out_file)
{
    // extract GPR registers
    for (int i = 0; i < 31; i++) {
        size_t offset = offsetof(struct axiom_exception_context, x[i]);
        fprintf(out_file, "#define AX_CTX_X%d\t\t%zu\n", i, offset);
    }
    
    for (int i = 0; i < sysreg_size; i++) {
        fprintf(out_file, "#define AX_CTX_%s\t\t%zu\n", sysregs[i].name, sysregs[i].offset);
    }
    
    fprintf(out_file, "#define AX_CTX_SIZE\t\t%zu\n",sizeof(struct axiom_exception_context));
}

int main()
{

	FILE *fp = fopen(fname, "w");
	if (!fp) {
		perror("fopen");
		return 1;
	}
	
	fprintf(fp, "/* Tool-Generated - DO NOT EDIT */\n\n");

	fprintf(fp, "#ifndef AXIOM_EXCEPTION_CTX_OFFSET_H\n#define AXIOM_EXCEPTION_CTX_OFFSET_H\n\n");
	
	fprintf(fp, "/* This header is generated as a C<->Assembly shared ABI contract about axiom_exception_offset struct \n and its member layout in memory as placed by compiler */\n\n");

    	extract_axiom_exception_offset(fp);

	fprintf(fp, "\n\n#endif\n");

	fclose(fp);

    return 0;
}
