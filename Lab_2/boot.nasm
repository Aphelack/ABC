[bits 16]
[org 0x7c00]

    jmp 0:kernel_start

gdt_start:

gdt_null:
    dd 0x0
    dd 0x0

gdt_code:
    dw 0xffff
    dw 0x0
    db 0x0
    db 10011010b
    db 11001111b
    db 0x0

gdt_data:
    dw 0xffff
    dw 0x0
    db 0x0
    db 10010010b
    db 11001111b
    db 0x0

gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start
    dd gdt_start

CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

print:
    pusha
    mov ah, 14
    mov bh, 0
.loop:
    lodsb
    cmp al, 0
    je .done
    int 0x10
    jmp .loop
.done:
    popa
    ret

textfor16 db 'Some text in 16 bit mode', 0
textfor32 db 'Some text in 32 bit mode!', 0

task1_text db 'Random text for task1', 0
task2_text db 'Another stupid text, but for task2', 0
task3_text db 'Who could have imagined',0

kernel_start:
    mov ax, 0
    mov ss, ax
    mov sp, 0xFFFC

    mov ax, 0
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    mov si, textfor16
    call print


    cli
    lgdt[gdt_descriptor]
    mov eax, cr0
    or eax, 0x1
    mov cr0, eax
    jmp CODE_SEG:b32

[bits 32]

VIDEO_MEMORY equ 0xb8000
WHITE_ON_BLACK equ 0x0f
GREEN equ 0x0A
RED equ 0x0C
YELLOW equ 0x0E

print32:
    mov edx, VIDEO_MEMORY
    mov ah, GREEN
.loop:
    mov al, [ebx]
    cmp al, 0
    je .done
    mov [edx], ax
    add ebx, 1
    add edx, 2
    jmp .loop
.done:
    ret

task1:
    mov ebx, task1_text
    mov edx, VIDEO_MEMORY
    mov ah, GREEN
    jmp print32.loop

task2:
    mov ebx, task1_text
    mov edx, VIDEO_MEMORY
    add edx, 160
    mov ah, YELLOW
    jmp print32.loop

task3:
    mov ebx, task1_text
    mov edx, VIDEO_MEMORY
    add edx, 320
    mov ah, RED
    jmp print32.loop

b32:
    mov ax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    mov ebp, 0x2000
    mov esp, ebp

    call task1
    call task2
    call task3

    jmp $

[SECTION signature start=0x7dfe]
dw 0AA55h