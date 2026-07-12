bits 16
org 0x7C00
jmp 0x0000:start
start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00
    sti
    cld

    mov [boot_drive], dl

    ; force 80x25 color text mode (mode 3)
    mov ah, 0x00
    mov al, 0x03
    int 0x10

    ; reset disk system (floppy-emulated USB needs this before reading)
    xor ah, ah
    mov dl, [boot_drive]
    int 0x13

    ; CHS read stage 2: 16 sectors from LBA 1 (C0 H0 S2) -> 0x7E00
    mov ax, 0x07E0
    mov es, ax
    xor bx, bx
    mov ah, 0x02
    mov al, 16
    mov ch, 0
    mov cl, 2
    mov dh, 0
    mov dl, [boot_drive]
    int 0x13
    jc disk_error

    jmp 0x0000:0x7E00

disk_error:
    mov ah, 0x0E
    mov al, 'E'
    int 0x10
halt:
    cli
    hlt
    jmp halt

boot_drive: db 0

times 510 - ($ - $$) db 0x00
dw 0xAA55
