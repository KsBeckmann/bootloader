; print a null-terminated string
; input: SI -> string
print:
  push ax
  push bx
  push si
  mov bh, 0
.loop:
  lodsb
  cmp al, 0
  je .done
  mov ah, 0x0E
  int 0x10
  jmp .loop
.done:
  pop si
  pop bx
  pop ax
  ret
