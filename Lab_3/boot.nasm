[bits 16]
[org 0x7c00]

jmp 0:start

gdt_start:
gdt_null: dd 0, 0
gdt_code: dw 0xffff, 0x0
          db 0x0, 10011010b, 11001111b, 0x0
gdt_data: dw 0xffff, 0x0
          db 0x0, 10010010b, 11001111b, 0x0
gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start
    dd gdt_start

CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

; Task table: [priority, function, exec_count]
tasks: dd 3, t1, 0, 1, t2, 0, 2, t3, 0

counter dd 0
round dd 1

ps:
    pusha
.l: lodsb
    test al, al
    jz .d
    mov dx, 0x3F8
    out dx, al
    jmp .l
.d: popa
    ret

pn: ; print number
    pusha
    add al, '0'
    mov dx, 0x3F8
    out dx, al
    popa
    ret

m1 db 27, '[95mLab3: Priority Scheduler', 27, '[0m', 13, 10, 0
m2 db 27, '[96mT1(P:3) T2(P:1) T3(P:2)', 27, '[0m', 13, 10, 0
rd db 'R', 0
sel db ':T', 0
ctr db ' C=', 0
nl db 13, 10, 0

start:
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0xFFFC

    mov si, m1
    call ps
    mov si, m2
    call ps

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

    ; Run multiple rounds to show different tasks
    mov ecx, 9
.rnd:
    push ecx
    
    ; Print round
    mov esi, rd
    call p32
    mov eax, [round]
    call pn32
    
    call sched
    
    ; Print counter
    mov esi, ctr
    call p32
    mov eax, [counter]
    call pn32
    mov esi, nl
    call p32
    
    inc dword [round]
    pop ecx
    dec ecx
    jnz .rnd
    jmp $

; Round-robin scheduler with priorities
sched:
    pusha
    mov eax, 0    ; best priority
    mov ebx, 0    ; best task index
    mov ecx, 0    ; current index
    mov edx, tasks
.lp:
    ; Skip if executed 3 times
    cmp dword [edx+8], 3
    jge .nx
    ; Compare priority
    cmp dword [edx], eax
    jle .nx
    mov eax, [edx]    ; best priority
    mov ebx, ecx      ; best task
.nx:
    add edx, 12
    inc ecx
    cmp ecx, 3
    jl .lp
    
    test eax, eax
    jz .done
    
    ; Print selected task
    mov esi, sel
    call p32
    mov eax, ebx
    inc eax
    call pn32
    
    ; Execute task
    mov edx, tasks
    mov eax, ebx
    mov edi, eax
    shl eax, 2    ; eax *= 4
    shl edi, 3    ; edi *= 8  
    add eax, edi  ; eax = ebx*12
    add edx, eax
    call [edx+4]
    inc dword [edx+8]  ; increment exec count
    
.done:
    popa
    ret

p32:
    pusha
.l: lodsb
    test al, al
    jz .d
    mov dx, 0x3F8
    out dx, al
    jmp .l
.d: popa
    ret

pn32:
    pusha
    add al, '0'
    mov dx, 0x3F8
    out dx, al
    popa
    ret

t1: ; High priority: counter++
    inc dword [counter]
    mov edi, 0xB8000
    mov al, [counter]
    add al, '0'
    mov ah, 0x0A
    mov [edi], ax
    ret

t2: ; Low priority: display counter
    mov edi, 0xB8000 + 160
    mov al, [counter]
    add al, '0'
    mov ah, 0x0E
    mov [edi], ax
    ret

t3: ; Medium priority: counter *= 2
    mov eax, [counter]
    shl eax, 1
    and eax, 7
    mov [counter], eax
    mov edi, 0xB8000 + 320
    add al, '0'
    mov ah, 0x0C
    mov [edi], ax
    ret

times 510-($-$$) db 0
dw 0AA55h