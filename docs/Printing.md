## Topics and understanding.
#### Digital Learning.

[x86 Architecture Overview.](https://cs.lmu.edu/~ray/notes/x86overview/)
[Video Memory.](https://forum.osdev.org/viewtopic.php?p=131248)
[Paging.](https://wiki.osdev.org/Paging)
[Real Mode.](https://wiki.osdev.org/Real_Mode)
[Screen Printing.](https://intermezzos.github.io/book/first-edition/hello-world.html)

#### Base concepts.
Video Memory.
<b>0xB0000</b> is the pointer to the Monochrome text mode.
<b>0xB8000</b> is the pointer address to the Color Text Mode.
<b>0xA0000</b> is the pointer address to the Graphical Mode.

We’re using the screen as a “memory mapped” device. Specific positions in memory correspond to certain positions on the screen. And the position 0xb8000 is one of those positions: the upper-left corner of the screen.

What this means is that memory on a computer isn't just representing things like RAM and your hard drive. Actual human-scale devices like the keyboard and mouse and video card have their own memory locations too. But instead of writing a byte to a hard drive for storage, the CPU might write a byte representing some color and symbol to the monitor for display.

There's an industry standard somewhere that says video memory must live in the address range beginning 0xb8000. In order for computers to be able to work out of the box, this means that the BIOS needs to be manufactured to assume video lives at that location, and the motherboard (which is where the bus is all wired up) has to be manufactured to route a 0xb8000 request to the video card. 

```text
 __ background color
/  __foreground color
| /
V V
0 2 48 <- letter, in ASCII
```
There are 16 colors available, each with a number. Here’s the table:

| Value | Color          |
|-------|----------------|
| 0x0   | black          |
| 0x1   | blue           |
| 0x2   | green          |
| 0x3   | cyan           |
| 0x4   | red            |
| 0x5   | magenta        |
| 0x6   | brown          |
| 0x7   | gray           |
| 0x8   | dark gray      |
| 0x9   | bright blue    |
| 0xA   | bright green   |
| 0xB   | bright cyan    |
| 0xC   | bright red     |
| 0xD   | bright magenta |
| 0xE   | yellow         |
| 0xF   | white          |