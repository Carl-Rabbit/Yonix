[org 0x7c00]

; set the screen to be text mod, and clear the screen
mov ax, 3
int 0x10

; init register
mov ax, 0
mov ds, ax
mov es, ax
mov ss, ax
mov sp, 0x7c00

mov si, booting
call print

mov edi, 0x1000; the target memory to store the data read from disk
mov ecx, 2; the start sector
mov bl, 4; number of sectors
call read_disk

cmp word [0x1000], 0x55aa
jnz error

jmp 0:0x1002

xchg bx, bx; bochs magic breakpiont

; block
jmp $

read_disk:

    ; set the number of sectors
    mov dx, 0x1f2
    mov al, bl
    out dx, al

    inc dx; 0x1f3
    mov al, cl; first 8 bits of start sector
    out dx, al

    inc dx; 0x1f4
    shr ecx, 8
    mov al, cl; second 8 bits of start sector
    out dx, al

    inc dx; 0x1f5
    shr ecx, 8
    mov al, cl; third 8 bits of start sector
    out dx, al

    inc dx; 0x1f6
    shr ecx, 8
    and cl, 0b1111; set the high 4 bits to be 0

    mov al, 0b1110_0000
    ;         7654 4321
    ; 4: 0, master disk
    ; 5/7: 1, fixed 1
    ; 6: 1, LBA mode
    or al, cl
    out dx, al; master disk - LBA mode

    inc dx; 0x1f7
    mov al, 0x20; read disk
    out dx, al

    xor ecx, ecx; use xor to clear ecx, = mov ecx, 0
    mov cl, bl; get the number of sector read

    .read:
        push cx; save cx
        call .waits; wait for the data to be prepared
        call .reads; read a sector
        pop cx; restore cx
        loop .read

    ret

    .waits:
        mov dx, 0x1f7
        .check:
            in al, dx
            jmp $+2; = nop, jump to next line, but spend more time cycle
            jmp $+2; delay
            jmp $+2
            and al, 0b1000_1000
            cmp al, 0b0000_1000
            jnz .check
        ret

    .reads:
        mov dx, 0x1f0
        mov cx, 256; one sector, 256 bytes
        .readw:
            in ax, dx
            jmp $+2; delay
            jmp $+2
            jmp $+2
            mov [edi], ax
            add edi, 2
            loop .readw
        ret

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

booting:
    db "Booting Yonix...", 10, 13, 0; \n\r

error:
    mov si, .msg
    call print
    hlt; let CPU stops
    jmp $
    .msg db "Booting Error!!!", 10, 13, 0
    

times 510 - ($ - $$) db 0

db 0x55, 0xaa
