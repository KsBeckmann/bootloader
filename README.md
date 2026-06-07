# bootloader
The purpose of this repository is to store study code on how a bootloader works

## Build

```bash
nasm boot.asm -o boot.bin
```

## Run

```bash
qemu-system-x86_64 -drive format=raw,file=boot.bin
```
