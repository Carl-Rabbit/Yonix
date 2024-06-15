[org 0x1000]

dw 0x55aa; magic number, used to check whether an error occur

xchg bx, bx; bochs magic breakpiont

mov si, loading
call print

xchg bx, bx; bochs magic breakpiont

detect_memory:
    xor ebx, ebx; set ebx to be 0

    ; es:di a place to store struct
    mov ax, 0
    mov es, ax; segment reg cannot mov a immidiate valu  e
    mov edi, ards_buffer

    mov edx, 0x534d4150; a fixed signature

.next:
    ; sub child number
    mov eax, 0xe820
    ; ards structure size (in byte)
    mov ecx, 20
    ; 0x15 system call
    int 0x15

    jc error; if CF is set, means error

    ; put the pointer to the next struct
    add di, cx

    ; increase the struct number
    inc word [ards_count]

    cmp ebx, 0
    jnz .next

    mov si, detecting
    call print

    xchg bx, bx; bochs magic breakpiont

    mov cx, [ards_count]
    mov si, 0; pointer of struct

.show:
    mov eax, [ards_buffer + si]
    mov ebx, [ards_buffer + si + 8]
    mov edx, [ards_buffer + si + 16]
    add si, 20
    xchg bx, bx; bochs magic breakpiont
    loop .show

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
detecting:
    db "Detecting Momory Success.", 10, 13, 0; \n\r

error:
    mov si, .msg
    call print
    hlt; let CPU stops
    jmp $
    .msg db "Loading Error!!!", 10, 13, 0

ards_count:
    dw 0
ards_buffer:
