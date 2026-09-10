CROSS_COMPILE := aarch64-none-elf-

LD	:= $(CROSS_COMPILE)ld
AS	:= $(CROSS_COMPILE)as
CC	:= $(CROSS_COMPILE)gcc
OBJCOPY := $(CROSS_COMPILE)objcopy


CPPFLAGS := -Iinclude
CFLAGS := -ffreestanding -fno-builtin
ASFLAGS :=
LDFLAGS :=

BUILD := build

OBJS := $(BUILD)/boot.o \
	$(BUILD)/level1_exceptions.o \
	$(BUILD)/cpu.o \
	$(BUILD)/axiom_main.o \
	$(BUILD)/console.o \
	$(BUILD)/pl011-uart.o

LINKER_SCRIPT := linker.ld
LINKER_SCRIPT_DEPS := \
		      include/platform/axiom-memory.h \
		      include/platform/qemu-virt.h

AXIOM_ELF	:= $(BUILD)/axiom.elf
AXIOM_BINARY	:= $(BUILD)/axiom.bin

.PHONY: all clean

all : $(AXIOM_BINARY)
	@echo "[BUILD]	$<"

$(AXIOM_BINARY): $(AXIOM_ELF)
	@echo "[OBJCOPY] $@"
	$(OBJCOPY) -O binary $< $@

$(AXIOM_ELF): $(OBJS) $(BUILD)/linker.i
	@echo "[LD]	$@"
	$(LD) $(LDFLAGS) -T $(BUILD)/linker.i -o $@ $(OBJS)

# preprocess the linker script so that macros from platform and memory headers are resolved
$(BUILD)/linker.i: $(LINKER_SCRIPT) $(LINKER_SCRIPT_DEPS)
	@echo "[CPP]	linker.ld"
	$(CC) -E -P -x c $(CPPFLAGS) $< -o $@

$(BUILD)/boot.o: arch/aarch64/boot.S
	@echo "[CC]	$<"
	$(CC) $(CPPFLAGS) -c $< -o $@

$(BUILD)/level1_exceptions.o: arch/aarch64/level1_exceptions.S
	@echo "[AS]	$<"
	$(AS) $(ASFLAGS) $< -o $@

$(BUILD)/cpu.o: arch/aarch64/cpu.S
	@echo "[AS]	$<"
	$(AS) $(ASFLAGS) $< -o $@

$(BUILD)/axiom_main.o: arch/aarch64/axiom_main.c
	@echo "[CC]	$<"
	$(CC) $(CPPFLAGS) $(CFLAGS) -c $< -o $@

$(BUILD)/console.o: runtime/console.c
	@echo "[CC]	$<"
	$(CC) $(CPPFLAGS) $(CFLAGS) -c $< -o $@

$(BUILD)/pl011-uart.o: drivers/pl011-uart/pl011-uart.c
	@echo "[CC]	$<"
	$(CC) $(CPPFLAGS) $(CFLAGS) -c $< -o $@

clean:
	@echo "[CLEAN]	build"
	rm -rf $(BUILD)/*
