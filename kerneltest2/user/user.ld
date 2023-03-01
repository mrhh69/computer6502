
SECTIONS {
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
  __data_start = ADDR(data);
  __data_size  = SIZEOF(data);
  __data_end = __data_start + __data_size;

  bss : {
    *(bss);
  }
  __bss_start = ADDR(bss);
  __bss_size = SIZEOF(bss);
  __bss_end = __bss_start + __bss_size;
}
