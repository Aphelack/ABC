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

    ; Enter protected mode
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
gdt_real:
    dw 0xffff, 0x0
    db 0x0, 10011010b, 00000000b, 0x0
gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start

CODE_SEG equ 8
DATA_SEG equ 16
REAL_SEG equ 24

start_msg db 27, '[96mLab 2: Real->Protected->Real Demo', 27, '[0m', 13, 10, 0

[bits 32]
pm:
    mov ax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov ss, ax

    mov esi, pm_msg
    call print32

    ; Show on screen
    mov edi, 0xB8000
    mov ax, 0x4F50  ; 'P' white on red
    mov [edi], ax
    mov ax, 0x4F4D  ; 'M' white on red  
    mov [edi+2], ax

    ; Test extended memory
    mov edi, 0x200000
    mov eax, 0xCAFEBABE
    mov [edi], eax
    cmp eax, [edi]
    je .ok
    
    mov esi, fail_msg
    call print32
    jmp .ret
.ok:
    mov esi, ok_msg
    call print32

.ret:
    ; Return to real mode
    jmp REAL_SEG:back

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

pm_msg db 27, '[94mProtected Mode Active!', 27, '[0m', 13, 10, 0
ok_msg db 27, '[92mMemory test OK', 27, '[0m', 13, 10, 0
fail_msg db 27, '[91mMemory test FAIL', 27, '[0m', 13, 10, 0

[bits 16]
back:
    mov eax, cr0
    and eax, 0xFFFFFFFE
    mov cr0, eax
    jmp 0:real

real:
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    sti

    mov si, back_msg
    call print_serial
    jmp $

back_msg db 27, '[92mBack in Real Mode!', 27, '[0m', 13, 10, 0

times 510-($-$$) db 0
dw 0xAA55