[org 0x7c00]

mov ax, 3
int 0x10

mov ax, 0
mov ds, ax
mov es, ax
mov ss, ax
mov sp, 0x7c00

mov ax, 0xb800
mov ds, ax
mov byte [0], 'H'
mov byte [2], 'e'
mov byte [4], 'l'
mov byte [6], 'l'
mov byte [8], 'o'
mov byte [10], ' '
mov byte [12], 'w'
mov byte [14], 'o'
mov byte [16], 'r'
mov byte [18], 'l'
mov byte [20], 'd'
mov byte [22], '!'
mov byte [24], '!'


jmp $

times 510 - ($ - $$) db 0

db 0x55, 0xaa
