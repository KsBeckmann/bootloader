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

cpuid_supported:     db "CPUID supported", 0x0D, 0x0A, 0
cpuid_not_supported: db "CPUID NOT supported", 0x0D, 0x0A, 0
