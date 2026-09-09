ENTRY(_start)

SECTIONS
{
	. = 0x0;

	.text : ALIGN(4)
	{
		KEEP(*(.text.boot))
		*(.text.*)
	}
}
