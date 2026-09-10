.PHONY: drivers misc all

# TODO: Revise and Arrange this Makefile, like make axiom.bin, axiom.elf etc as the primary build targets, define make variables, add separate build/ or out/ directory, etc
all:	drivers misc
	#aarch64-none-elf-as -o boot.o arch/aarch64/boot.S - replace -as tool with -gcc -c because now our .S includes a include directive for a .h header file
	aarch64-none-elf-gcc -Iinclude -c arch/aarch64/boot.S -o boot.o
	aarch64-none-elf-as -o level1_exceptions.o arch/aarch64/level1_exceptions.S
	aarch64-none-elf-as -o cpu.o arch/aarch64/cpu.S
# include our C source file in the Make process
	aarch64-none-elf-gcc -ffreestanding -fno-builtin -Iinclude -c arch/aarch64/axiom_main.c -o axiom_main.o
# preprocess the linker script first, as it has include directives, and ld tool doesnot necessarily understands the #include natively
	aarch64-none-elf-gcc -E -P -x c -Iinclude linker.ld -o linker.i

	aarch64-none-elf-ld -T linker.i -o axiom.elf boot.o level1_exceptions.o axiom_main.o cpu.o \
			console.o pl011-uart.o

	aarch64-none-elf-objcopy -O binary axiom.elf axiom.bin

drivers:
	aarch64-none-elf-gcc -ffreestanding -fno-builtin -Iinclude -c drivers/pl011-uart/pl011-uart.c -o pl011-uart.o 

misc: drivers
	aarch64-none-elf-gcc -ffreestanding -fno-builtin -Iinclude -c runtime/console.c -o console.o


clean:
	rm -f axiom.elf axiom.bin boot.o level1_exceptions.o axiom_main.o cpu.o console.o pl011-uart.o linker.i
