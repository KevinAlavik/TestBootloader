SRC_DIR := src
BOOT_DIR := $(SRC_DIR)/bootloader
KERNEL_DIR := $(SRC_DIR)/kernel
BIN_DIR := bin
BUILD_DIR := build

BOOT_ENTRY := $(BOOT_DIR)/boot.asm
LOADER_ENTRY := $(BOOT_DIR)/loader.asm
KERNEL_ENTRY := $(KERNEL_DIR)/kernel.c

AS := nasm
LD := i686-elf-ld
CC := i686-elf-gcc
QEMU := qemu-system-i386
QEMU_FLAGS := -serial stdio -name "Test Bootloader" -drive format=raw,file=$(BIN_DIR)/final.img


CC_FLAGS := -std=gnu99 -ffreestanding -O2 -Wall -Wextra -nostdlib -lgcc

LD_FLAGS := -T linker.ld

$(shell mkdir -p $(BIN_DIR))
$(shell mkdir -p $(BUILD_DIR))

all: $(BIN_DIR)/final.img

$(BUILD_DIR)/kernel.o: $(KERNEL_ENTRY)
	@printf "  CC\t$<\n"
	@$(CC) $(CC_FLAGS) -c $< -o $@

$(BUILD_DIR)/loader.o: $(LOADER_ENTRY)
	@printf "  AS\t$<\n"
	@$(AS) -f elf32 -o $@ $<

$(BIN_DIR)/boot.img: $(BOOT_ENTRY)
	@printf "  AS\t$<\n"
	@$(AS) -f bin -o $@ $<

$(BIN_DIR)/kernel.img: $(BUILD_DIR)/kernel.o $(BUILD_DIR)/loader.o
	@printf "  LD\t$@\n"
	@$(LD) $(LD_FLAGS) -o $@ $^

$(BIN_DIR)/final.img: $(BIN_DIR)/boot.img $(BIN_DIR)/kernel.img
	@printf "  OUT\t$@\n"
	@cat $^ > $@

run: $(BIN_DIR)/final.img
	@$(QEMU) $(QEMU_FLAGS)

clean:
	rm -rf build/* bin/*
