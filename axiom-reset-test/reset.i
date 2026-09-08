.macro mov_imm reg, value
    movz \reg, ((\value >> 0) & 0xffff)
    movk \reg, ((\value >> 16) & 0xffff), lsl #16
    movk \reg, ((\value >> 32) & 0xffff), lsl #32
    movk \reg, ((\value >> 48) & 0xffff), lsl #48
.endm
.section .text.boot
.globl _start
.type _start, %function
_start:
 ldr x0, =__stack_top
 mov sp, x0
 mrs x1, SCTLR_EL3
 mrs x2, SCR_EL3
 mrs x3, VBAR_EL3
 mrs x4, DAIF
 ldr x0, =vector_table
 msr VBAR_EL3, x0
 isb
 mov_imm x0, ((1U << 29) | (1U << 28) | (1U << 23) | (1U << 22) | (1U << 18) | (1U << 16) | (1U << 11) | (1U << 5) | (1U << 4) & ~((1ULL << 25) | (1ULL << 19) | (1ULL << 12) | (1ULL << 6) | (1ULL << 2) | (1ULL << 1) | (1ULL << 0)))
 orr x0, x0, #(1ULL << 3)
 msr SCTLR_EL3, x0
 isb
1:
 b 1b
