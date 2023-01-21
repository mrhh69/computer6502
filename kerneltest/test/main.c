#include "kernel.h"


/* clib.s: */
extern void lcd_init(__reg("a") char cursor_on, __reg("r0") char cursor_blink);
extern void lcd_instruction(__reg("a") unsigned char instruction);
extern void putc(__reg("a") char c);
extern void pause();
/* kernel.s: */
extern void systemd();
//extern void memcpy(char * src, char * dst, unsigned int length);
extern void swtchin(__reg("r0/r1") char * ppda);


union process processes[8];
struct handler handlers_ca1[4];
struct handler handlers_timer1[4];

extern void goin();

int main() {

  /* initialize handlers (to 0) - no need (already in bss) */
  /*
  for (i = 0; i < 4; i++) {
    handlers_ca1[i].func = 0;
    handlers_timer1[i].func = 0;
  }
  */
  goin();
}
