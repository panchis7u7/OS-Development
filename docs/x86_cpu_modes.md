## Topics and understanding.
#### Digital Learning.

## x86 CPU modes.
A modern x86 processor can operate in one of four major modes: 

#### <b>1. 16-bit real mode.</b>
Real Mode is a simplistic 16-bit mode that is present on all x86 processors. Real Mode was the first x86 mode design and was used by many early operating systems before the birth of Protected Mode. For compatibility purposes, all x86 processors begin execution in Real Mode.

Memory access is done using segmentation, There are six 16-bit segment registers: CS, DS, ES, FS, GS, and SS. When using segment registers, addresses are given with the following notation (where 'Segment' is a value in a segment register and 'Offset' is a value in an address register):

<b> 12F3 (segment)  :  4B27 (offset) </b>

Segments and Offsets are related to physical addresses by the equation:

 <b> PhysicalAddress = Segment * 16 + Offset </b>

+ No memory protection.
+ No multitasking. 
+ No process priviledge.

#### <b>2. 16-bit protected mode.</b>
This is the only protected mode available on 80286 processors. Segments can have any length between 1 and 216 = 64 kilobytes. A segment base has 24 bits on an 80286 CPU, limiting the available address space to 16 megabytes. On 386 and higher CPUs, a segment base can have 32 bits. Thus, even in 16-bit protected mode, the complete 32-bit address space of 4 gigabytes is available (although many segments are required to use the complete address space).

Near pointers are 16-bit offsets interpreted relative to a segment register. Far pointers consist of a 16-bit selector and a 16-bit offset.

#### <b>3. 32-bit protected mode.</b>


#### <b>4. 64-bit long mode.</b>
64-bit long mode is more of a break from the “legacy” modes. Long mode obsoletes several instructions. It is also the only mode in which 64-bit registers are available; 64-bit registers cannot be accessed from either 16-bit or 32-bit mode. Also, unlike the other modes, most encoded values in long mode are limited to 32 bits in size. A small subset of the MOV instructions allow 64 bit encoded values, but values greater than 32 bits in other instructions must come from a register. Partly due to this limitation, but also due to the wide use of relocatable shared libraries, long mode also adds a new addressing mode: RIP-relative.
