bits 32
protected_mode_start:
  mov ax, 0x10
  mov ds, ax
  mov es, ax
  mov fs, ax
  mov gs, ax
  mov ss, ax
  mov esp, 0x90000

  jmp 0x10000

.hang:
  cli
  hlt
  jmp .hang
