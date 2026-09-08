/* Basic CPU ASM Interface for Axiom Level 1 */


.globl axiom_read_current_el
.type axiom_read_current_el, %function

axiom_read_current_el:
	mrs x0, CurrentEL
	ret
