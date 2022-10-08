section .data
multiboot_msg db "Multiboot found!.",0
cpuid_msg db "CPUID information found!",0
long_mode_msg db "Long mode is supported!",0
ok_msg db "[OK] ",0
ok_msg_len equ $-ok_msg-1
fail_msg db "[FAIL] ",0
fail_msg_len equ $-fail_msg-1
video_space equ 0xb8000

section .bss
align 4096
video_space_offset:
    resw 1
L4_page_table:
    resb 4096
L3_page_table:
    resb 4096
L2_page_table:
    resb 4096
stack_bottom:
    resb 4096 * 4
stack_top:

section .rodata
; Define Global Descriptor Table.
gdt64:
    dq 0    ; Zero entry.
    ; Code Segment: 
    ; Enable executable flag.
    ; Set descriptor tpye for code and data segments.
    ; Enable present flag.
    ; Enable 64 bit flag.
.code_segment: equ $-gdt64
    dq (1 << 43) | (1 << 44) | (1 << 47) | (1 << 53)
    ; Long pointer that holds 2 bytes of the length of the table
.pointer:
    dw $-gdt64-1
    dq gdt64


global start:
extern long_mode_start
section .text
bits 32
start:
    push eax
    mov ax, 0
    mov [video_space_offset], ax
    pop eax
    mov esp, stack_top

    ; Print OK.
    ; mov dword [0xb8000], 0x2f4b2f4f
    call check_multiboot     
    call check_cpuid
    call check_long_mode
    call setup_page_tables

    lgdt [gdt64.pointer]
    jmp gdt64.code_segment:long_mode_start

; -------------------------------------------------
check_multiboot:
    mov esi, ok_msg
    mov ebx, fail_msg
    cmp eax, 0x36d76289         ; Multiboot magic number check.
    cmovne esi, ebx             ; Pass the okay message.
    call print
    mov esi, multiboot_msg
    call print
    ret

; -------------------------------------------------
; Flip the cpuid bit of the flags register.
check_cpuid:
    pushfd
    pop eax
    mov ecx, eax
    xor eax, 1 << 21        ; Flip the 21 bit.
    push eax
    popfd
    pushfd
    pop eax
    push ecx
    popfd
    mov esi, ok_msg
    mov ebx, fail_msg
    cmp eax, ecx
    cmove esi, ebx            ; Pass the okay message.
    call print
    mov esi, cpuid_msg
    call print
    ret

; -------------------------------------------------
; Check if cpuid suppots extended processor info.
check_long_mode:
    mov esi, ok_msg
    mov ecx, fail_msg
    mov eax, 0x80000000
    cpuid
    cmp eax, 0x80000001
    jl .no_long_mode
    cmovl esi, ecx
    mov eax, 0x80000001
    cpuid
    test edx, 1 << 29
    jz .no_long_mode
    ret
.no_long_mode:
    mov esi, fail_msg
    call print
    mov esi, cpuid_msg
    call print
    ret

; ---------------------------------------------------------------------------------------
; Paging.
; Allows to map virtual address to physical addresses. In order to acomplish this
; it is necessary to create page tables definin the mappings which the cpu then
; looks at whenever you try to read or write to memory.
;
; A single page is a chunk of 4Kb of memory, each tabla can hold 512 entries. Each
; virtual address takes up 48 bits pf the 64 bit available, the remaining bits are
; unused. The CPU treats the first 9 bits as an index into the L4 page table and the 
; corresponding entry will point to a L3 page table, the CPU then uses the next 9
; bits to index into this L3 page table, yielding an entry pointing to a L2 page
; table. This continues until we reach the L1 page table where the entry now points
; to the start of a page in physical memory. The final bits of the virtual address
; are used as an offset in this physical page. The cpu determines tha address of the
; L4 page table at any moment by reading the pointer stored in the CR3 register.
setup_page_tables:
    
    ; We need to do identity mapping where we map a physicall address to the exact
    ; same virtual address.Becauls paging will be enabled automatically as soon as
    ; enable long mode.
    ;
    ; 1. Point the first entry of L4 to the first entry in the L3 table.
    ; 2. Each entry in a page table contains an address, but it also 
    ; contains metadata about that page. The first two bits are the 
    ; ‘present bit’ and the ‘writable bit’. By setting the first bit, 
    ; we say “this page is currently in memory,” and by setting the 
    ; second, we say “this page is allowed to be written to.”
    ; 3. The 0 is intended to convey to the reader that we’re accessing 
    ; the zeroth entry in the page table.   
    mov eax, L3_page_table
    or eax, 0b11                            ; Present, Writable flags.
    mov dword [L4_page_table + 0], eax

    ; -------------------------------------------------------------------
    ; 1. Point the first entry of L3 to the first entry in the L2 table.
    mov eax, L2_page_table
    or eax, 0b11
    mov dword [L3_page_table + 0], eax

    ; -------------------------------------------------------------------
    ; 1. Point each table L2 entry to a page.
    ; 2. This extra 1 is a ‘huge page’ bit, meaning that the pages are 
    ; 2,097,152 bytes. Without this bit, we’d have 4KiB pages instead of 
    ; 2MiB pages.
    ; 3. We skip eight spaces each time, so we have room for all eight bytes 
    ; of the page table entry.
    mov ecx, 0          ; Counter variable.
.map_p2_table:
    mov eax, 0x200000   ; Each page is 2MiB in size. 
    mul ecx
    or eax, 0b10000011
    mov [L2_page_table + ecx * 8], eax

    inc eax
    cmp ecx, 512
    jne .map_p2_table

enable_paging:
    ; -------------------------------------------------------------------
    ; 1. Now that we have a valid page table, we need to inform the 
    ; hardware about it. cr3 is a special register, called a 
    ; ‘control register’, hence the cr. The cr registers are special: 
    ; they control how the CPU actually works. In our case, the cr3 
    ; register needs to hold the location of the page table.
    mov eax, L4_page_table
    mov cr3, eax

    ; -------------------------------------------------------------------
    ; Enable physical address extension "PAE".
    ; In order to set PAE, we need to take the value in the cr4 register 
    ; and modify it. So first, we mov it into eax, then we use or to change 
    ; the value. What about 1 << 5? The << is a ‘left shift’. This is necesary 
    ; for 64 bit paging.
    mov eax, cr4
    or eax, 1 << 5
    mov cr4, eax

    ; -------------------------------------------------------------------
    ; Set long mode bit.
    ; The rdmsr and wrmsr instructions read and write to a ‘model specific 
    ; register’, hence msr. This is just what you have to do to set this up.
    mov ecx, 0xC0000080
    rdmsr
    or eax, 1 << 8
    wrmsr

    ; -------------------------------------------------------------------
    ; Enable paging!
    ; cr0 is the register we need to modify. We do the usual “move to eax, 
    ; set some bits, move back to the register” pattern. In this case, 
    ; we set bit 31 and bit 16.
    mov eax, cr0
    or eax, 1 << 31
    or eax, 1 << 16
    mov cr0, eax

    ; -------------------------------------------------------------------
    ; So, technically after paging is enabled, we are in long mode. But 
    ; we’re not in real long mode; we’re in a special compatibility mode. 
    ; To get to real long mode, we need a data structure called a 
    ; ‘global descriptor table’.
    ;
    ; The GDT is used for a style of memory handling called ‘segmentation’, 
    ; which is in contrast to the paging model that we just set up. Even 
    ; though we’re not using segmentation, however, we’re still required 
    ; to have a valid GDT.
    ;
    ; The GDT will have three entries:
    ; ‘zero entry’
    ; ‘code segment’
    ; ‘data segment’

    ret

; -------------------------------------------------------------------
; Input esi (data), edx (length)
print:
    lea ebx, [esi]          ; Point to the same address as the parameter supplied to esi.
    xor ecx, ecx            ; Clear counter.
    xor edx, edx            ; Clear character holder.
    mov al, 0x0F            ; Black Background with white text character.
    mov edi, 0x02
    mov esi, [video_space_offset]
print_loop:
    mov edx, [ebx+ecx]                  ; Offset the characters.
    cmp dl, 0x5B                        
    cmove eax, edi
    mov [video_space+(esi*2)], dl    ; Black Background with white text character.
    mov [video_space+(esi*2)+1], al  ; Copy the nth character to the nth + 1 address.
    inc ecx                          ; Increment counter +1.
    inc esi
    cmp dl, 0                        ; Check if string terminator was encounterd.
    je success
    jmp print_loop
success:
    dec esi
    mov [video_space_offset], esi
    ret