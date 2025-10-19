# Lab 3: Advanced Multitasking System - Enhanced Version
# Demonstrates priority-based task scheduling in protected mode

.PHONY: all build run clean demo

all: build

build:
	@echo "=== Building Lab 3: Priority Scheduler ==="
	@mkdir -p build
	nasm -f bin -o build/boot.bin boot.nasm
	@echo "Bootloader size: $$(wc -c < build/boot.bin) bytes (max 512)"
	@echo "Build complete!"

run: build
	@echo "=== Lab 3: Advanced Multitasking System ==="
	@echo "Features:"
	@echo "  • Priority-based task scheduling"
	@echo "  • Inter-task communication via shared memory"
	@echo "  • Task state management"
	@echo "  • VGA text mode output with colors"
	@echo ""
	@echo "Expected behavior:"
	@echo "  • Tasks execute in priority order (3 > 2 > 1)"
	@echo "  • Shared counter demonstrates inter-task communication"
	@echo "  • Screen output shows task execution"
	@echo ""
	@echo "Bootloader output:"
	@echo ""
	@echo "" | timeout 6 qemu-system-x86_64 -drive file=build/boot.bin,format=raw -serial stdio -display none || true
	@echo ""
	@echo "=== Lab 3 execution completed ==="
	@echo ""
	@echo "Educational concepts demonstrated:"
	@echo "  ✓ Protected mode setup with GDT"
	@echo "  ✓ Priority-based task scheduling algorithm"
	@echo "  ✓ Task Control Block (TCB) management"
	@echo "  ✓ Inter-task shared memory communication"
	@echo "  ✓ Multiple task states (Ready, Running)"
	@echo "  ✓ Memory-mapped VGA output"

demo: run

clean:
	@echo "Cleaning Lab 3 build artifacts..."
	@rm -rf build/*
	@echo "Clean complete!"

# Development targets
debug: build
	@echo "=== Lab 3 Debug Mode ==="
	@echo "Starting QEMU with monitor for debugging..."
	@echo "Use 'info registers' and 'x/10i \$$pc' in monitor"
	qemu-system-x86_64 -drive file=build/boot.bin,format=raw -monitor stdio

size: build
	@echo "=== Lab 3 Size Analysis ==="
	@echo "Bootloader: $$(wc -c < build/boot.bin) bytes"
	@echo "Free space: $$((512 - $$(wc -c < build/boot.bin))) bytes"
	@objdump -D -b binary -m i386 -M intel build/boot.bin | head -20