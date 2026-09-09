all:
	#aarch64-none-elf-as -o boot.o arch/aarch64/boot.S - replace -as tool with -gcc -c because now our .S includes a include directive for a .h header file
	aarch64-none-elf-gcc -Iinclude -c arch/aarch64/boot.S -o boot.o
	aarch64-none-elf-as -o level1_exceptions.o arch/aarch64/level1_exceptions.S
	aarch64-none-elf-as -o cpu.o arch/aarch64/cpu.S
# include our C source file in the Make process
	aarch64-none-elf-gcc -ffreestanding -fno-builtin -c arch/aarch64/axiom_main.c -o axiom_main.o
# preprocess the linker script first, as it has include directives, and ld tool doesnot necessarily understands the #include natively
	aarch64-none-elf-gcc -E -P -x c -Iinclude linker.ld -o linker.i

	aarch64-none-elf-ld -T linker.i -o axiom.elf boot.o level1_exceptions.o axiom_main.o cpu.o
	aarch64-none-elf-objcopy -O binary axiom.elf axiom.bin
clean:
	rm axiom.elf axiom.bin boot.o level1_exceptions.o axiom_main.o cpu.o
