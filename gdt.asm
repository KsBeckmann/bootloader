load_gdt:
  lgdt [gdt_descriptor]
  mov si, gdt_message
  call print
  ret

gdt_message: db "GDT loaded", 0x0D, 0x0A, 0

gdt_start:
  dq 0x0000000000000000
  dw 0xFFFF
  dw 0x0000
  db 0x00
  db 10011010b
  db 11001111b
  db 0x00

  dw 0xFFFF
  dw 0x0000
  db 0x00
  db 10010010b
  db 11001111b
  db 0x00
gdt_end:

gdt_descriptor:
  dw gdt_end - gdt_start - 1
  dd gdt_start
