bits 16
org 0x7C00

jmp 0x0000:start
start:

cli
xor ax, ax
mov ds, ax
mov es, ax
mov fs, ax
mov gs, ax
mov ss, ax
mov sp, 0x7C00
sti
cld

; clear screen
mov ah, 0x06
mov al, 0x00
mov bh, 0x07
xor cx, cx
mov dh, 0x18
mov dl, 0x4F
int 0x10

; move cursor to 0,0
mov ah, 0x02
xor bh, bh
xor dx, dx
int 0x10

; startup message
mov si, starting_boot
call print

; check CPUID
pushfd
pop eax
mov ecx, eax
xor eax, 0x00200000
push eax
popfd
pushfd
pop eax
xor eax, ecx
and eax, 0x00200000
jz no_cpuid

mov si, cpuid_supported
call print

; check A20 line
xor ax, ax
mov es, ax
mov ax, 0xFFFF
mov fs, ax

mov byte [es:0x0500], 0x00
mov byte [fs:0x0510], 0xFF

mov al, [es:0x0500]
cmp al, [fs:0x0510]
jne .skip
call enable_a20
.skip:

mov si, a20_enabled
call print

; GDT flat
lgdt [gdt_descriptor]
mov si, gdt_message
call print

halt:
  hlt
  jmp halt

no_cpuid:
  mov si, cpuid_not_supported
  call print
  jmp halt

enable_a20:
  mov si, a20_disabled
  call print
  push ax
  mov ax, 0x2401
  int 0x15
  pop ax
  ret

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

starting_boot:       db "starting bootloader...", 0x0D, 0x0A, 0
cpuid_supported:     db "CPUID supported", 0x0D, 0x0A, 0
cpuid_not_supported: db "CPUID NOT supported", 0x0D, 0x0A, 0
a20_enabled:         db "A20 enabled", 0x0D, 0x0A, 0
a20_disabled:        db "A20 disabled", 0x0D, 0x0A, 0
gdt_message:         db "GDT loaded", 0x0D, 0x0A, 0

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

times 510 - ($ - $$) db 0x00
dw 0xAA55
