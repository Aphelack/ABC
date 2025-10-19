# Lab 2: Protected Mode Bootloader Makefile

.PHONY: all build run clean demo

# Default target
all: build

# Build the bootloader
build:
	@mkdir -p build
	nasm -f bin -o build/boot.bin boot.nasm
	@echo "Build completed: build/boot.bin"

# Run the bootloader with console output
run: build
	@echo "=== Lab 2: Protected Mode Bootloader ==="
	@echo "Bootloader output:"
	@echo ""
	@echo "" | timeout 3 qemu-system-x86_64 -drive file=build/boot.bin,format=raw -serial stdio -display none || true
	@echo ""
	@echo "=== Execution completed ==="

# Alternative run method without timeout
run-notimeout: build
	@echo "=== Lab 2: Protected Mode Bootloader (no timeout) ==="
	@echo "Running bootloader - press Ctrl+C to stop:"
	@echo ""
	qemu-system-x86_64 -drive file=build/boot.bin,format=raw -serial stdio -display none

# Run with VGA display
run-gui: build
	@echo "Running with graphical display..."
	qemu-system-x86_64 -drive file=build/boot.bin,format=raw

# Clean build artifacts
clean:
	rm -rf build/*
	@echo "Cleaned build directory"

# Demo (same as run)
demo: run

# Show bootloader info
info:
	@echo "Lab 2: Protected Mode Bootloader"
	@echo "Files:"
	@ls -la boot.nasm build/ 2>/dev/null || echo "  (build directory empty)"
	@echo ""
	@echo "Usage:"
	@echo "  make build    - Build the bootloader"
	@echo "  make run      - Run with timeout and console output"
	@echo "  make run-notimeout - Run without timeout"
	@echo "  make run-gui  - Run with graphical display"
	@echo "  make clean    - Clean build artifacts"