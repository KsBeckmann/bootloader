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
mov dh, 0x0C
mov dl, 0x23
int 0x10

; print hello
mov si, 0x00
init_loop:
  mov al, [hello + si]
  mov [si_save], si
  mov ah, 0x0E
  mov bh, 0x00
  int 0x10
  mov si, [si_save]
  add si, 0x01
  cmp byte [hello + si], 0x00
  jne init_loop

; halt
halt:
  ; workaround: keeps calling BIOS to prevent firmware from rebooting on inactivity
  mov ah, 0x0E
  mov al, 0x08
  mov bh, 0x00
  int 0x10
  jmp halt

si_save: dw 0

hello:
  db "hello >:(", 0x00

times 510 - ($ - $$) db 0x00
dw 0xAA55
