
SECTIONS {
	. = 0x8000;
	__filling_section : AT(0) {
		RESERVE(0x400);
		FILL8(0);
	}
  . = 0x8400;
  .text.entry : AT(0x400) {
    *(.text.entry)
  }

  text : {
    *(text);
  }
  rodata : {
    *(rodata);
  }
  __text_size = SIZEOF(text) + SIZEOF(rodata);

  user.text : {
    *(.text);
  }

  user.data : {
    *(.data);
  }
  user.bss (NOLOAD) : {
    *(.bss);
  }
  __user_data_loc = LOADADDR(user.data);


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
