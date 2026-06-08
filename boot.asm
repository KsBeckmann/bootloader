bits 16
org 0x7C00

; constants
BLUE:  equ 0x09
BROWN: equ 0x06

; video mode
xor ah, ah
mov al, 0x13
int 0x10

; fill blue
mov ax, 0xA000
mov es, ax
xor di, di
mov cx, 0xFA00
mov al, BLUE
rep stosb

mov di, 0xE182
mov al, BROWN
call draw_rect

; keyboard input
game_loop:
  mov ah, 0x01
  int 0x16
  jz game_loop
  mov ah, 0x00
  int 0x16
  cmp ah, 0x4B
  je left
  cmp ah, 0x4D
  je right
  jmp game_loop

left:
  cmp word [plat_x], 0
  jle game_loop

  mov di, 0xE100
  add di, [plat_x]
  mov al, BLUE
  call draw_rect

  sub word [plat_x], 0x04

  mov di, 0xE100
  add di, [plat_x]
  mov al, BROWN
  call draw_rect
  jmp game_loop

right:
  cmp word [plat_x], 0x104
  jge game_loop

  mov di, 0xE100
  add di, [plat_x]
  mov al, BLUE
  call draw_rect

  add word [plat_x], 0x04

  mov di, 0xE100
  add di, [plat_x]
  mov al, BROWN
  call draw_rect
  jmp game_loop

halt:
  jmp halt

; DI -> initial position
; AL -> color
draw_rect:
  mov cx, 0x08
.line:
  push cx
  push di
  mov cx, 0x3C
  rep stosb
  pop di
  add di, 0x140
  pop cx
  loop .line
  ret

plat_x: dw 0x82

times 510 - ($ - $$) db 0x00
dw 0xAA55
