[bits 16]
[org 0x7c00]

start:
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7c00

    mov si, start_msg
    call print_serial

    cli
    lgdt [gdt_descriptor]
    mov eax, cr0
    or eax, 1
    mov cr0, eax
    jmp CODE_SEG:pm

print_serial:
    pusha
.loop:
    lodsb
    test al, al
    jz .done
    mov dx, 0x3F8
    out dx, al
    jmp .loop
.done:
    popa
    ret

gdt_start:
gdt_null:
    dd 0x0, 0x0
gdt_code:
    dw 0xffff, 0x0
    db 0x0, 10011010b, 11001111b, 0x0
gdt_data:
    dw 0xffff, 0x0
    db 0x0, 10010010b, 11001111b, 0x0
gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start

CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

start_msg db 27, '[96mLab 2: Starting...', 27, '[0m', 13, 10, 0

[bits 32]
pm:
    mov ax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov ss, ax

    mov esi, pm_msg
    call print32

    call task1
    call task2
    call task3

    mov esi, done_msg
    call print32
    jmp $

print32:
    pusha
.loop:
    lodsb
    test al, al
    jz .done
    mov dx, 0x3F8
    out dx, al
    jmp .loop
.done:
    popa
    ret

task1:
    mov esi, t1_msg
    call print32
    mov edi, 0xB8000
    mov ax, 0x0A31
    mov [edi], ax
    ret

task2:
    mov esi, t2_msg
    call print32
    mov edi, 0xB8000 + 160
    mov ax, 0x0E32
    mov [edi], ax
    ret

task3:
    mov esi, t3_msg
    call print32
    mov edi, 0xB8000 + 320
    mov ax, 0x0C33
    mov [edi], ax
    ret

pm_msg db 27, '[94m32-bit mode', 27, '[0m', 13, 10, 0
t1_msg db 27, '[92mTask1: GREEN', 27, '[0m', 13, 10, 0
t2_msg db 27, '[93mTask2: YELLOW', 27, '[0m', 13, 10, 0
t3_msg db 27, '[91mTask3: RED', 27, '[0m', 13, 10, 0
done_msg db 27, '[95mComplete!', 27, '[0m', 13, 10, 0

times 510-($-$$) db 0
dw 0xAA55