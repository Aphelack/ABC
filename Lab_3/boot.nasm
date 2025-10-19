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

; Lab 3 messages
msg1 db 27, '[95mLab3: Advanced Multitasking', 27, '[0m', 13, 10, 0
msg2 db 27, '[94mScheduler active', 27, '[0m', 13, 10, 0
t1 db 27, '[92mTask1 running', 27, '[0m', 13, 10, 0
t2 db 27, '[93mTask2 running', 27, '[0m', 13, 10, 0
t3 db 27, '[91mTask3 running', 27, '[0m', 13, 10, 0
fin db 27, '[95mComplete', 27, '[0m', 13, 10, 0

start:
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0xFFFC

    mov si, msg1
    call print_serial

    cli
    lgdt [gdt_descriptor]
    mov eax, cr0
    or eax, 1
    mov cr0, eax
    jmp CODE_SEG:pm

[bits 32]
pm:
    mov ax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov ss, ax

    mov esi, msg2
    call print32

    ; Schedule tasks
    mov ecx, 3
.loop:
    call task1
    call task2
    call task3
    dec ecx
    jnz .loop

    mov esi, fin
    call print32
    jmp $

print32:
    pusha
.lp:
    lodsb
    test al, al
    jz .dn
    mov dx, 0x3F8
    out dx, al
    jmp .lp
.dn:
    popa
    ret

task1:
    mov esi, t1
    call print32
    mov edi, 0xB8000
    mov ax, 0x0A31
    mov [edi], ax
    ret

task2:
    mov esi, t2
    call print32
    mov edi, 0xB8000 + 160
    mov ax, 0x0E32
    mov [edi], ax
    ret

task3:
    mov esi, t3
    call print32
    mov edi, 0xB8000 + 320
    mov ax, 0x0C33
    mov [edi], ax
    ret

times 510-($-$$) db 0
dw 0AA55h