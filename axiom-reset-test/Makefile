all:
	aarch64-none-elf-as -o cpu.o cpu.S
	aarch64-none-elf-gcc -Iplatform -c reset.S -o reset.o	
	#aarch64-none-elf-as -o reset.o reset.S
	aarch64-none-elf-as -o level1_exceptions.o level1_exceptions.S
	# include our C source file in the Make process
	aarch64-none-elf-gcc -ffreestanding -fno-builtin -c axiom_main.c -o axiom_main.o
	# preprocess the linker script first, as it has include directives, and ld tool doesnot necessarily understands the #include natively
	aarch64-none-elf-gcc -E -P -x c -Iplatform linker.ld -o linker.i
	# the above preprocess-only command took the linker script (linker.ld) as input and preprocessed it using the headers so now it can understand the #include directives and spat linker.i
	aarch64-none-elf-ld -T linker.i -o reset.elf reset.o level1_exceptions.o axiom_main.o cpu.o
	aarch64-none-elf-objcopy -O binary reset.elf reset.bin
clean:
	rm linker.i reset.o level1_exceptions.o reset.elf reset.bin 
