bits 32
protected_mode_start:
  mov ax, 0x10
  mov ds, ax
  mov es, ax
  mov fs, ax
  mov gs, ax
  mov ss, ax
  mov esp, 0x90000

  %include "paging.asm"

  jmp 0x18:long_mode_start

.hang:
  cli
  hlt
  jmp .hang

  %include "long_mode.asm"
