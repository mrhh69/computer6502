
SECTIONS {
  . = 0x8000;
  .text.entry : AT(0) {
    *(.text.entry)
  }

  text : {
    *(text);
  }
  rodata : {
    *(rodata);
  }
  __text_size = SIZEOF(text) + SIZEOF(rodata);


  . = 0x1000;
  data : {
    *(data);
  }
  __data_loc = LOADADDR(data) + 0x8000;
  __data_start = ADDR(data);
  __data_size  = SIZEOF(data);
  __data_end = __data_start + __data_size;

  bss (NOLOAD) : {
    *(bss);
  }
  __bss_start = ADDR(bss);
  __bss_size = SIZEOF(bss);
  __bss_end = __bss_start + __bss_size;


  . = 0xfffa;
  .text.vectors : AT(0x7ffa) {
    *(.text.vectors);
  }
}
