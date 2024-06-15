[org 0x1000]

dw 0x55aa; magic number, used to check whether an error occur

xchg bx, bx; boxhs magic breakpiont

mov si, loading
call print

; blocking
jmp $

print:
    mov ah, 0x0e
.next:
    mov al, [si]
    cmp al, 0
    jz .done
    int 0x10
    inc si
    jmp .next
.done:
    ret

loading:
    db "Loading Yonix...", 10, 13, 0; \n\r
