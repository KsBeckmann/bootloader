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

mov [boot_drive], dl

; force 80x25 color text mode (mode 3) -- some BIOSes boot in 40-column mode
mov ah, 0x00
mov al, 0x03
int 0x10

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

call check_cpuid

call check_a20

call load_gdt

; load kernel via LBA (int 0x13 AH=0x42) -> robust, no CHS track-boundary limit
mov si, dap
mov ah, 0x42
mov dl, [boot_drive]
int 0x13
jc disk_error

; inform BIOS of target processor mode
mov ax, 0xEC00
mov bl, 0x01      ; 1 = legacy (32 bits)
int 0x15

; enter protected mode
cli
mov eax, cr0
or eax, 1
mov cr0, eax
jmp 0x08:protected_mode_start

halt:
  hlt
  jmp halt

%include "print.asm"
%include "cpuid.asm"
%include "a20.asm"
%include "gdt.asm"
%include "protected_mode.asm"

disk_error:
    mov si, disk_error_msg
    call print
    jmp halt

boot_drive:    db 0

; Disk Address Packet for the LBA read (int 0x13 AH=0x42)
dap:
    db 0x10           ; packet size (16 bytes)
    db 0x00           ; reserved
    dw 16             ; sectors to read
    dw 0x0000         ; destination offset
    dw 0x1000         ; destination segment (0x1000:0000 = 0x10000)
    dq 1              ; starting LBA (sector 0 = boot sector, kernel at LBA 1)

starting_boot: db "starting bootloader...", 0x0D, 0x0A, 0
disk_error_msg: db "disk read error", 0x0D, 0x0A, 0

times 510 - ($ - $$) db 0x00
dw 0xAA55
