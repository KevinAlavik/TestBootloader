[org 0x7C00]

section .data
    welcome db 'Hello, World!', 0
    DISK db 0

; Save disk number for later
mov [DISK], dl

; Set video mode to mode 3 (80x25 text mode)
mov ah, 0x00
mov al, 0x03
int 0x10

; Set up stack
mov bp, 0x7C00
mov sp, bp

; Enable A20 line
in al, 0x92
or al, 2
out 0x92, al

jmp loader

loader:
    mov si, welcome
    call puts
    jmp $

; Internal print function
puts:
    pusha
next_char:
    lodsb
    or al, al
    jz done
    mov ah, 0x0E
    int 0x10
    jmp next_char
done:
    popa
    ret


times 510-($-$$) db 0
dw 0xaa55
