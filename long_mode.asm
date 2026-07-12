bits 64
long_mode_start:
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov ss, ax

    mov rsi, 0xB8000
    mov word [rsi], 0x2F4C

    mov rsp, 0x90000
    mov rax, 0x10000
    jmp rax
