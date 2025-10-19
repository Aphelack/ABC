# Lab 2: Protected Mode Bootloader

This project demonstrates a bootloader that switches from 16-bit real mode to 32-bit protected mode and executes multiple tasks with colored output.

## Features

- **16-bit to 32-bit mode switching**: Complete GDT setup and protected mode transition
- **Colored console output**: Real ANSI color codes for terminal display
- **Multi-task simulation**: Three tasks writing to both video memory and serial console
- **Video memory output**: Tasks write colored text to VGA memory at 0xB8000

## Files

- `boot.nasm` - Original bootloader with VGA output
- `boot_simple.nasm` - Optimized bootloader with ANSI colored console output
- `justfile` - Build system with multiple targets

## Usage

### Run with colored console output (recommended):
```bash
just run-color
```

### Run with VGA display:
```bash
just run
```

### Clean build artifacts:
```bash
just clean
```

## Output

The bootloader displays:
- **Cyan**: Startup and completion messages
- **Blue**: Mode transition messages  
- **Green**: Task 1 output
- **Yellow**: Task 2 output
- **Red**: Task 3 output

Each task also writes to video memory with corresponding VGA colors.

## Technical Details

- Boot sector size: 512 bytes
- Target: x86 architecture
- Emulator: QEMU
- Assembly: NASM
- Serial output via port 0x3F8
- VGA text mode at 0xB8000