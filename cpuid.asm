CPUID_EXT equ 0x80000000
CPUID_EXT_FEATURES equ 0x80000001
CPUID_EDX_EXT_FEAT_LM equ 1 << 29

check_cpuid:
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
  jnz .cpuid_ok

  mov si, cpuid_not_supported
  call print
  jmp halt

.cpuid_ok:
  mov si, cpuid_supported
  call print
  ret

require_long_mode:
  mov eax, CPUID_EXT
  cpuid
  cmp eax, CPUID_EXT_FEATURES
  jb .no_long_mode

  mov eax, CPUID_EXT_FEATURES
  cpuid
  test edx, CPUID_EDX_EXT_FEAT_LM
  jz .no_long_mode

  mov si, long_mode_msg
  call print
  ret

.no_long_mode:
  mov si, no_long_mode_msg
  call print
  jmp halt

cpuid_supported:     db "CPUID supported", 0x0D, 0x0A, 0
cpuid_not_supported: db "CPUID NOT supported", 0x0D, 0x0A, 0
long_mode_msg:       db "long mode supported", 0x0D, 0x0A, 0
no_long_mode_msg:    db "long mode not supported", 0x0D, 0x0A, 0
