all:
	aarch64-none-elf-as -o boot.o arch/aarch64/boot.S
# preprocess the linker script first, as it has include directives, and ld tool doesnot necessarily understands the #include natively
	aarch64-none-elf-gcc -E -P -x c -Iinclude linker.ld -o linker.i

	aarch64-none-elf-ld -T linker.i -o axiom.elf boot.o
	aarch64-none-elf-objcopy -O binary axiom.elf axiom.bin
clean:
	rm axiom.elf axiom.bin boot.o
