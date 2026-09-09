all:
	aarch64-none-elf-as -o boot.o arch/aarch64/boot.S

	aarch64-none-elf-ld -T linker.ld -o axiom.elf boot.o
	aarch64-none-elf-objcopy -O binary axiom.elf axiom.bin
clean:
	rm axiom.elf axiom.bin boot.o
