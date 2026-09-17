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

EL3_LINKER_SCRIPT := linker.ld
LINKER_SCRIPT_DEPS := \
		      include/platform/axiom-memory.h \
		      include/platform/qemu-virt.h

AXIOM_ELF	:= $(BUILD)/axiom.elf
AXIOM_BINARY	:= $(BUILD)/axiom.bin

EL2_EL3_HANDOFF_HEADER	:= include/generated/el2-build-layout.h
EL2_MAKE_TARGET		:= el2

.PHONY: all clean rebuild

rebuild:
	make clean
	make all

all : $(AXIOM_BINARY)
	@echo "[BUILD]	$<"

$(AXIOM_BINARY): $(AXIOM_ELF)
	@echo "[OBJCOPY] $@"
	$(OBJCOPY) -O binary $< $@

$(AXIOM_ELF): $(EL2_MAKE_TARGET) $(EL2_EL3_HANDOFF_HEADER) $(OBJS) $(BUILD)/linker.i
	@echo "[LD]	$@"
	$(LD) $(LDFLAGS) -T $(BUILD)/linker.i -o $@ $(OBJS)

# preprocess the linker script so that macros from platform and memory headers are resolved
$(BUILD)/linker.i: $(EL3_LINKER_SCRIPT) $(LINKER_SCRIPT_DEPS)
	@echo "[CPP]	linker.ld"
	$(CC) -E -P -x c $(CPPFLAGS) $< -o $@

$(BUILD)/boot.o: arch/aarch64/boot.S $(EL2_EL3_HANDOFF_HEADER)
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

clean: el2_clean el1_clean
	@echo "[CLEAN]	build"
	rm -rf $(BUILD)/*

# EL2 Build Steps

EL2_ELF			:= $(BUILD)/el2.elf
EL2_BINARY		:= $(BUILD)/el2.bin
EL2_LINKER_SCRIPT	:= linker.el2.ld

EL1_MAKE_TARGET		:= el1

# NOTE: added the $(BUILD)/console.o $(BUILD)/pl011-uart.o to add links to the console and uart driver so that it could be used to print logs
EL2_OBJS	:= $(BUILD)/level2_exceptions.o \
		   $(BUILD)/el2.o \
		   $(BUILD)/console.o \
		   $(BUILD)/pl011-uart.o \
		   $(BUILD)/el2_main.o \
		   $(BUILD)/el2_exceptions.o

EL2_CTX_C_ASM_OFFS_HEADER	:=	generated/axiom-exception-ctx-offset.h
EL1_EL2_HANDOFF_HEADER	:= include/generated/el1-build-layout.h

# NOTE: right now, EL2 elf is being explicitly built as a target to be then manually loaded via qemu at designated address in memory

el2: $(EL2_BINARY)
	@echo "[BUILD]	$<"

$(EL2_BINARY): $(EL2_ELF)
	@echo "[OBJCOPY] $@"
	$(OBJCOPY) -O binary $< $@

$(EL2_ELF): $(EL1_MAKE_TARGET) $(EL1_EL2_HANDOFF_HEADER) $(BUILD)/linker.el2.i $(EL2_OBJS)
	@echo "[LD]	$@"
	$(LD) $(LDFLAGS) -T $(BUILD)/linker.el2.i -o $@ $(EL2_OBJS)

$(EL2_EL3_HANDOFF_HEADER): $(EL2_ELF)
	@echo "[TOOL]	$@"
	./tools/generate-elf-symbols.sh el2 $<

# preprocess the linker script so that macros from platform and memory headers are resolved
$(BUILD)/linker.el2.i: $(EL2_LINKER_SCRIPT) $(LINKER_SCRIPT_DEPS)
	@echo "[CPP]	linker.el2.ld"
	$(CC) -E -P -x c $(CPPFLAGS) $< -o $@

$(BUILD)/el2_main.o: arch/aarch64/el2_main.c
	@echo "[CC]	$<"
	$(CC) $(CPPFLAGS) $(CFLAGS) -c $< -o $@

$(BUILD)/el2.o: arch/aarch64/el2.S
	@echo "[CC]	$<"
	$(CC) $(CPPFLAGS) -c $< -o $@

$(BUILD)/level2_exceptions.o: arch/aarch64/level2_exceptions.S $(EL2_CTX_C_ASM_OFFS_HEADER)
	@echo "[CC]	$<"
	$(CC) $(CPPFLAGS) -c $< -o $@

$(BUILD)/el2_exceptions.o: runtime/el2_exceptions.c
	@echo "[CC]	$<"
	$(CC) $(CPPFLAGS) $(CFLAGS) -c $< -o $@

$(EL2_CTX_C_ASM_OFFS_HEADER): 
	./tools/generate-axiom-exception-ctx-offsets.o

el2_clean:
	@echo "[CLEAN] build - EL2"
	rm -rf $(BUILD)/linker.el2.i $(BUILD)/el2* level2_exceptions.o $(EL2_EL3_HANDOFF_HEADER) $(EL2_CTX_C_ASM_OFFS_HEADER)

# EL1 Build Steps

EL1_ELF			:= $(BUILD)/el1.elf
EL1_BINARY		:= $(BUILD)/el1.bin
EL1_LINKER_SCRIPT	:= linker.el1.ld

EL1_OBJS		:= $(BUILD)/el1.o \
			   $(BUILD)/level3_exceptions.o \
			   $(BUILD)/console.o \
			   $(BUILD)/pl011-uart.o \
			   $(BUILD)/el1_main.o

el1: $(EL1_BINARY) 
	@echo "[BUILD]	$<"

$(EL1_BINARY): $(EL1_ELF)
	@echo "[OBJCOPY] $@"
	$(OBJCOPY) -O binary $< $@

$(EL1_ELF) : $(BUILD)/linker.el1.i $(EL1_OBJS)
	@echo "[LD]	$@"
	$(LD) $(LDFLAGS) -T $(BUILD)/linker.el1.i -o $@ $(EL1_OBJS)

$(EL1_EL2_HANDOFF_HEADER): $(EL1_ELF)
	@echo "[TOOL]	$@"
	./tools/generate-elf-symbols.sh el1 $<

# preprocess the linker script so that macros from platform and memory headers are resolved
$(BUILD)/linker.el1.i: $(EL1_LINKER_SCRIPT) $(LINKER_SCRIPT_DEPS)
	@echo "[CPP]	linker.el1.i"
	$(CC) -E -P -x c $(CPPFLAGS) $< -o $@

$(BUILD)/el1.o: arch/aarch64/el1.S
	@echo "[CC]	$<"
	$(CC) $(CPPFLAGS) -c $< -o $@

$(BUILD)/level3_exceptions.o: arch/aarch64/level3_exceptions.S
	@echo "[CC]	$<"
	$(CC) $(CPPFLAGS) $(CFLAGS) -c $< -o $@

$(BUILD)/el1_main.o: arch/aarch64/el1_main.c
	@echo "[CC]	$<"
	$(CC) $(CPPFLAGS) $(CFLAGS) -c $< -o $@

el1_clean:
	@echo "[CLEAN] build - EL1"
	rm -rf $(BUILD)/linker.el1.i $(BUILD)/el1* $(BUILD)/level3_exceptions.o $(EL1_EL2_HANDOFF_HEADER)
