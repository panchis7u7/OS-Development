global long_mode_start

section .text
bits 64
long_mode_start:
    ; Load null into all data segment registers.
    mov ax, 0
    mov ss, ax
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    mov dword [0xb8000], 0x2f4f2f4b
    hlt