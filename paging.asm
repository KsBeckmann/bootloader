CR0_PAGING equ 1 << 31

PML4T_ADDR equ 0x1000
PDPT_ADDR equ 0x2000
PDT_ADDR equ 0x3000
PT_ADDR equ 0x4000

SIZEOF_PAGE_TABLE equ 4096

PT_ADDR_MASK equ 0xFFFFFFFFFF000
PT_PRESENT equ 1
PT_READABLE equ 2

ENTRIES_PER_PT equ 512
SIZEOF_PT_ENTRY equ 8
PAGE_SIZE equ 0x1000

CR4_PAE_ENABLE equ 1 << 5

EFFER_MSR equ 0xC0000080
EFFER_LM_ENABLE equ 1 << 8

CR0_PM_ENABLE equ 1 << 0
CR0_PG_ENABLE equ 1 << 31

; disable paging 32
    mov eax, cr0
    and eax, ~CR0_PAGING
    mov cr0, eax

; clear tables
    mov edi, PML4T_ADDR
    mov cr3, edi

    xor eax, eax
    mov ecx, SIZEOF_PAGE_TABLE
    rep stosd
    mov edi, cr3

; link first entries
    mov DWORD [edi], PDPT_ADDR & PT_ADDR_MASK | PT_PRESENT | PT_READABLE

    mov edi, PDPT_ADDR
    mov DWORD [edi], PDT_ADDR & PT_ADDR_MASK | PT_PRESENT | PT_READABLE

    mov edi, PDT_ADDR
    mov DWORD [edi], PT_ADDR & PT_ADDR_MASK | PT_PRESENT | PT_READABLE

; fill page tables
    mov edi, PT_ADDR
    mov ebx, PT_PRESENT | PT_READABLE
    mov ecx, ENTRIES_PER_PT

.set_entry:
    mov DWORD [edi], ebx
    add ebx, PAGE_SIZE
    add edi, SIZEOF_PT_ENTRY
    loop .set_entry

; enable PAE
    mov eax, cr4
    or eax, CR4_PAE_ENABLE
    mov cr4, eax

; switch to compatibility mode
    mov ecx, EFFER_MSR
    rdmsr
    or eax, EFFER_LM_ENABLE
    wrmsr

; enable paging (PG)
    mov eax, cr0
    or eax, CR0_PG_ENABLE | CR0_PM_ENABLE
    mov cr0, eax
