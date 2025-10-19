[bits 16]
[org 0x7c00]

    jmp 0:start

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
    dw gdt_end - gdt_start
    dd gdt_start

CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

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

; Compact messages with ANSI colors
msg1 db 27, '[96mBootloader Start', 27, '[0m', 13, 10, 0
msg2 db 27, '[94m16-bit mode', 27, '[0m', 13, 10, 0  
msg3 db 27, '[93mSwitching to 32-bit...', 27, '[0m', 13, 10, 0
msg4 db 27, '[94m32-bit mode active', 27, '[0m', 13, 10, 0
msg5 db 27, '[92mTask 1: GREEN text', 27, '[0m', 13, 10, 0
msg6 db 27, '[93mTask 2: YELLOW text', 27, '[0m', 13, 10, 0
msg7 db 27, '[91mTask 3: RED text', 27, '[0m', 13, 10, 0
msg8 db 27, '[96mTasks Complete!', 27, '[0m', 13, 10, 0

start:
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0xFFFC

    mov si, msg1
    call print_serial
    mov si, msg2
    call print_serial
    mov si, msg3
    call print_serial

    ; Switch to protected mode
    cli
    lgdt [gdt_descriptor]
    mov eax, cr0
    or eax, 1
    mov cr0, eax
    jmp CODE_SEG:mode32

[bits 32]
mode32:
    mov ax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov ss, ax

    mov esi, msg4
    call print32
    mov esi, msg5
    call print32
    call task1_video
    mov esi, msg6
    call print32
    call task2_video
    mov esi, msg7
    call print32
    call task3_video
    mov esi, msg8
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

task1_video:
    mov edi, 0xB8000
    mov ax, 0x0A31  ; Green '1'
    mov [edi], ax
    ret

task2_video:
    mov edi, 0xB8000 + 160
    mov ax, 0x0E32  ; Yellow '2'
    mov [edi], ax
    ret

task3_video:
    mov edi, 0xB8000 + 320
    mov ax, 0x0C33  ; Red '3'
    mov [edi], ax
    ret

times 510-($-$$) db 0
dw 0AA55h