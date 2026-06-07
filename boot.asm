bits 16
org 0x7C00

; setup
xor ax, ax
mov ds, ax
mov es, ax
mov ss, ax
mov sp, 0x7C00

; clear screen
mov ah, 0x06
mov al, 0x00
mov bh, 0x0C
xor cx, cx
mov dh, 0x18
mov dl, 0x4F
int 0x10

; move cursor
mov ah, 0x02
xor bh, bh
xor dx, dx
mov dh, 0x0
mov dl, 0x0
int 0x10

; print keyboard input
keyboard_loop:
  xor ah, ah
  int 0x16
  mov ah, 0x0E
  int 0x10
  jmp keyboard_loop

halt:
  jmp halt

; hello:
;   db "hello >:(", 0x00

times 510 - ($ - $$) db 0x00
dw 0xAA55
