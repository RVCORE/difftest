OUTPUT_ARCH(riscv)
ENTRY(_start)
BASE_ADDRESS = 0x10000000;

SECTIONS
{
  . = BASE_ADDRESS;
  .text : {
      *(entry)
      *(.text*)
  }
  . = ALIGN(4K);
  .rodata : {
      *(.rodata .rodata.*)
      *(.srodata .srodata.*)
  }
  . = ALIGN(4K);
  .data : {
      *(.data*)
      *(.sdata*)
  }
  . = ALIGN(4K);
  edata = .;
  .bss : {
      sbss = .;
      *(.bss*)
      *(.sbss*)
  }
  . = ALIGN(4K);
  _stack_top = .;
  . = _stack_top + 0x8000;
  _stack_pointer = .;
  . = ALIGN(4K);
  _heap_start = .;
}