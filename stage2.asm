bits 16
org 0x7E00
stage2_start:
    mov[boot_drive], dl

    mov si, starting_boot
    call print

    call check_cpuid
    call require_long_mode
    call check_a20
    call load_gdt

    call read_kernel

    mov dx, 0x3D4
    mov al, 0x0F
    out dx, al
    inc dx
    mov al, 0xFF
    out dx, al

    mov dx, 0x3D4
    mov al, 0x0E
    out dx, al
    inc dx
    mov al, 0xFF
    out dx, al

    cli
    mov eax, cr0
    or eax, 1
    mov cr0, eax
    jmp 0x08:protected_mode_start

halt:
    cli
    hlt
    jmp halt

%include "print.asm"
%include "cpuid.asm"
%include "a20.asm"
%include "gdt.asm"
%include "protected_mode.asm"

bits 16
disk_error:
    mov si, disk_error_msg
    call print
    jmp halt

; loads 120 sectors from LBA 9 to 0x1000:0000 via CHS (floppy-safe, sector by sector)
read_kernel:
    mov ah, 0x08              ; get drive geometry
    mov dl, [boot_drive]
    int 0x13
    jc disk_error
    and cl, 0x3F             ; CL[5:0] = sectors per track
    xor ch, ch
    mov [spt], cx
    mov cl, dh               ; DH = max head index
    xor ch, ch
    inc cx                   ; heads = max_head + 1
    mov [heads], cx

    xor ah, ah               ; reset disk
    mov dl, [boot_drive]
    int 0x13

    mov word [cur_lba], 9
    mov word [left], 120
    mov word [cur_seg], 0x1000
.next:
    cmp word [left], 0
    je .done

    mov ax, [cur_lba]        ; LBA -> CHS
    xor dx, dx
    div word [spt]
    inc dx
    mov [t_sec], dl          ; sector = (lba % spt) + 1
    xor dx, dx
    div word [heads]
    mov [t_cyl], al          ; cylinder
    mov [t_head], dl         ; head

    mov ax, [cur_seg]
    mov es, ax
    xor bx, bx
    mov ah, 0x02
    mov al, 1
    mov ch, [t_cyl]
    mov cl, [t_sec]
    mov dh, [t_head]
    mov dl, [boot_drive]
    int 0x13
    jc disk_error

    add word [cur_seg], 0x20  ; +512 bytes
    inc word [cur_lba]
    dec word [left]
    jmp .next
.done:
    ret

boot_drive: db 0
spt:      dw 0
heads:    dw 0
cur_lba:  dw 0
left:     dw 0
cur_seg:  dw 0
t_sec:    db 0
t_cyl:    db 0
t_head:   db 0

starting_boot: db "starting bootloader...", 0x0D, 0x0A, 0
disk_error_msg: db "disk read error", 0x0D, 0x0A, 0
