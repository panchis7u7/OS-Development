[Paging.](https://intermezzos.github.io/book/first-edition/paging.html)

What is paging? Paging is a way of managing memory. Our computer has memory, and we can think of memory as being a big long list of cells:

| address  | value |
|----------|-------|
| 0x00	   |   0   |   
| 0x01	   |   0   |
| 0x02	   |   0   |
| 0x03	   |   0   |
| 0x04	   |   0   |
|  ...     |  ...  |

Each location in memory has an address, and we can use the address to distinguish between the cells: the value at cell zero, the value at cell ten.

But how many cells are there? This question has two answers: The first answer is how much physical memory (RAM) do we have in our machine? This will vary per machine. My machine has 8 gigabytes of memory or 8,589,934,592 bytes. But maybe your machine has 4 gigabytes of memory, or sixteen gigabytes of memory.

The second answer to how many cells there are is how many addresses can be used to refer to cells of memory? To answer that we need to figure out how many different unique numbers we can make. In 64-bit mode, we can create as many addresses as can be expressed by a 64-bit number. So that means we can make addresses from zero to (2^64) - 1. That’s 18,446,744,073,709,551,616 addresses! We sometimes refer to a sequence of addresses as an ‘address space’, so we might say “The full 64-bit address space has 2^64 addresses.”

So now we have an imbalance. We have only roughly 8.5 billion actual physical memory slots in an 8GB machine but quintillions of possible addresses we can make.

How can we resolve this imbalance? <b>We don't want to be able to address memory that doesn't exist!</b>

Here’s the strategy: we introduce two kinds of addresses: physical addresses and virtual addresses. A physical address is the actual, real value of a location in the physical RAM in the machine. A virtual address is an address anywhere inside of our 64-bit address space: the full range. To bridge between the two address spaces, we can map a given virtual address to a particular physical address. So we might say something like “virtual address 0x044a maps to the physical address 0x0011.” Software uses the virtual addresses, and the hardware uses physical addresses.

Mapping each individual address would be extremely inefficient; we would need to keep track of literally every memory address and where it points to. Instead, we split up memory into chunks, also called ‘pages’, and then map each page to an equal sized chunk of physical memory.