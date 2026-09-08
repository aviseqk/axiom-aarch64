MEMORY
{
 BOOTROM (rx): ORIGIN = 0x00000000, LENGTH = 0x00020000
 SECURE_RAM( rwx): ORIGIN = 0x0E000000, LENGTH = 0x00010000
}
ENTRY(_start)
SECTIONS
{
 . = 0x00000000;
 .text : ALIGN(4)
 {
  KEEP(*(.text.boot))
  *(.text*)
 } > BOOTROM
 .vectors : ALIGN(2048)
 {
  __vector_table_start = .;
  KEEP(*(.vectors))
  __vector_table_end = .;
 } > BOOTROM
 .rodata : ALIGN(8)
 {
  *(.rodata*)
 } > BOOTROM
 . = 0x0E000000;
 .data : ALIGN(8)
 {
  __data_start = .;
  *(.data*)
  __data_end = .;
 } > SECURE_RAM AT>BOOTROM
 __data_load = LOADADDR(.data);
 .bss (NOLOAD): ALIGN(8)
 {
  __bss_start = .;
  *(.bss*)
  *(COMMON)
  __bss_end = .;
 } > SECURE_RAM
 .stack (NOLOAD): ALIGN(16)
 {
  __stack_bottom = .;
  . += 0x00004000;
  __stack_top = .;
 } > SECURE_RAM
 ASSERT(__stack_top <= 0x0E000000 + 0x00010000,
  "Axiom secure RAM overflow")
 ASSERT(__vector_table_start % 2048 == 0,
  "Level1 Vector Table not 2KiB aligned")
 ASSERT(__vector_table_end - __vector_table_start == 0x800,
  "Level1 Vector Table is not 2KiB in size")
}
