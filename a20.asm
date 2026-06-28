; checks the A20 line, enabling it if needed, then prints the final status
; clobbers: nothing (saves/restores ES/FS)
check_a20:
  push es
  push fs

  call a20_test          ; AX = 1 (on) / 0 (off)
  test ax, ax
  jnz .enabled

  call enable_a20        ; off -> try to enable
  call a20_test          ; re-check to confirm it actually turned on
  test ax, ax
  jnz .enabled

  ; still off
  mov si, a20_disabled
  call print
  jmp .done

.enabled:
  mov si, a20_enabled
  call print

.done:
  pop fs
  pop es
  ret

; tests whether the A20 line is enabled
; returns: AX = 1 if enabled, AX = 0 if disabled
; clobbers: AX, ES, FS
a20_test:
  xor ax, ax
  mov es, ax             ; ES = 0x0000 -> low address
  mov ax, 0xFFFF
  mov fs, ax             ; FS = 0xFFFF -> high address (wraps if A20 off)

  mov byte [es:0x0500], 0x00
  mov byte [fs:0x0510], 0xFF

  mov al, [es:0x0500]
  cmp al, [fs:0x0510]
  je .disabled           ; collided -> A20 off

  mov ax, 1
  ret

.disabled:
  xor ax, ax
  ret

; enables the A20 line via the BIOS
; clobbers: nothing (saves/restores AX)
enable_a20:
  push ax
  mov ax, 0x2401
  int 0x15
  pop ax
  ret

a20_enabled:  db "A20 enabled", 0x0D, 0x0A, 0
a20_disabled: db "A20 disabled", 0x0D, 0x0A, 0
