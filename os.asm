
org 0x7C00
bits 16

start:
    xor ax, ax
    mov ds, ax
    mov ss, ax
    mov sp, 0x7A00

    mov ax, 3
    int 0x10

    mov ax, 0x0600
    mov bh, 0x1F
    mov cx, 0
    mov dx, 0x184F
    int 0x10

    mov si, prompt
    call print
    mov byte [state], 0

main:
    mov ah, 0
    int 0x16

    cmp al, 0
    je main

    cmp al, 13
    je calc

    cmp al, '0'
    jb check_op
    cmp al, '9'
    ja check_op

    sub al, '0'
    cmp byte [state], 0
    je save_a
    cmp byte [state], 2
    je save_b
    jmp main

save_a:
    mov [a], al
    mov byte [state], 1
    add al, '0'
    call echo
    jmp main

save_b:
    mov [b], al
    mov byte [state], 3
    add al, '0'
    call echo
    jmp main

check_op:
    cmp byte [state], 1
    jne main
    cmp al, '+'
    je save_op
    cmp al, '-'
    je save_op
    jmp main

save_op:
    mov [op], al
    mov byte [state], 2
    call echo
    jmp main

calc:
    cmp byte [state], 3
    jne main

    call nl          ; ⬅️ ENTER sonrası alt satır

    mov al, [a]
    mov bl, [b]

    cmp byte [op], '+'
    je do_add

    sub al, bl
    js negative
    jmp show

do_add:
    add al, bl
    jmp show

negative:
    neg al
    mov si, minus
    call print

show:
    call print_number
    call nl          ; ⬅️ sonuçtan sonra alt satır

    mov si, prompt
    call print
    mov byte [state], 0
    jmp main

; -------- SAYI YAZDIRMA (0–99) --------
print_number:
    xor ah, ah
    mov bl, 10
    div bl            ; AL=onlar, AH=birler

    cmp al, 0
    je .ones
    add al, '0'
    call echo

.ones:
    mov al, ah
    add al, '0'
    call echo
    ret

; -------- IO --------
echo:
    mov ah, 0x0E
    mov bh, 0
    mov bl, 0x0F
    int 0x10
    ret

print:
.next:
    lodsb
    or al, al
    jz .done
    call echo
    jmp .next
.done:
    ret

nl:
    mov al, 13
    call echo
    mov al, 10
    call echo
    ret

prompt db ">_",0
minus  db "-",0
a db 0
b db 0
op db 0
state db 0

times 510-($-$$) db 0
dw 0xAA55
