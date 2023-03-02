
SECTIONS {
  __file_start = .;
  .header : AT(0) {
    *(.header);
  }
  text : {
    *(text);
  }
  rodata : {
    *(rodata);
  }
  __text_size = SIZEOF(text) + SIZEOF(rodata);

  . = 0x0200;
  data : {
    *(data);
  }
  __data_loc = LOADADDR(data) + __file_start;
  __data_start = ADDR(data);
  __data_size  = SIZEOF(data);
  __data_end = __data_start + __data_size;

  bss : {
    *(bss);
  }
  __bss_start = ADDR(bss);
  __bss_size = SIZEOF(bss);
  __bss_end = __bss_start + __bss_size;

  ASSERT((__data_start >> 8) == 0x02, "data is not on page $02");
  ASSERT((__data_size >> 8) == 0, "data_size > $ff");
  ASSERT((__bss_start >> 8) == 0x02, "bss is not on page $02");
  ASSERT((__bss_size >> 8) == 0, "bss_size > $ff");
}
