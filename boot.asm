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

call print_vendor
call print_cpu_brand

halt:
  hlt
  jmp halt

no_cpuid:
  mov si, cpuid_not_supported
  call print
  jmp halt

print_vendor:
  push eax
  push ebx
  push ecx
  push edx

  xor eax, eax
  mov si, msg_vendor
  call print
  cpuid
  mov [vendor_id+0], ebx
  mov [vendor_id+4], edx
  mov [vendor_id+8], ecx
  mov si, vendor_id
  call print

  mov si, break_line
  call print

  pop edx
  pop ecx
  pop ebx
  pop eax
  ret

print_cpu_brand:
  push eax
  push ebx
  push ecx
  push edx

  mov si, msg_cpu_brand
  call print
  
  mov eax, 0x80000002
  cpuid
  mov [cpu_brand+0],  eax
  mov [cpu_brand+4],  ebx
  mov [cpu_brand+8],  ecx
  mov [cpu_brand+12], edx

  mov eax, 0x80000003
  cpuid
  mov [cpu_brand+16],  eax
  mov [cpu_brand+20],  ebx
  mov [cpu_brand+24],  ecx
  mov [cpu_brand+28], edx

  mov eax, 0x80000004
  cpuid
  mov [cpu_brand+32],  eax
  mov [cpu_brand+36],  ebx
  mov [cpu_brand+40],  ecx
  mov [cpu_brand+44],  edx

  mov si, cpu_brand
  call print

  ; mov si, break_line
  ; call print

  pop edx
  pop ecx
  pop ebx
  pop eax
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
msg_vendor:          db "vendor id: ", 0
vendor_id:           times 13 db 0
msg_cpu_brand:       db "cpu brand: ", 0
cpu_brand:           times 49 db 0
break_line:          db 0x0D, 0x0A, 0

times 510 - ($ - $$) db 0x00
dw 0xAA55
