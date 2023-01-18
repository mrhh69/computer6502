#include "kernel.h"

#define PORTB  ((char *)0x6000)
#define PORTA  ((char *)0x6001)
#define DDRB   ((char *)0x6002)
#define DDRA   ((char *)0x6003)
#define T1CL   ((char *)0x6004) /* t1 counter high/low (write is a write to latches, not counter) */
#define T1CH   ((char *)0x6005) /* write into t1ch initiates countdown */
#define ACR    ((char *)0x600B)
#define PCR    ((char *)0x600C) /* CA,CB Control (interrupt lines) */
#define IFR    ((char *)0x600D) /* Interrupt Flags Register */
#define IER    ((char *)0x600E) /* Interrupt Enable Register */

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


void cli() = "cli";

void main() {
  /* initialize VIA 6522 */
  *DDRA = *DDRB = 0xff;
  *PORTA = *PORTB = 0;
  *ACR = 0x00; /* timer1 one-shot interrupt after loaded */
  *PCR = 0x00; /* ca1 disabled */
  *IER = 0xc0; /* Interrupts: timer1 enabled, ca1 disabled */
  *IFR = 0;    /* reset flags to null */

  /* NOTE: timer1 one-shot is necessary for lcd initialization */
  /* TODO: use timer2 instead for initialization (because it is one-shot only) */
  cli();
  lcd_init(1, 0);
  putc('i');

  *PCR = 0x01; /* ca1 enabled */
  *IER = 0xc2; /* Interrupts: timer1 enabled, ca1 enabled */
  *IFR = 0; // clear flags register?
  *ACR = 0x40; /* timer1 continuous interrupts after loaded */
  *T1CL = 0xff;
  *T1CH = 0xff; /* timer1 countdown start */


  /* initialize processes: */
  /*
  unsigned char i;
  for (i = 0; i < 8; i++) {
    processes[i].proc.pid = 0;
    processes[i].proc.flags = 0;
  }
  */
  /* initialize handlers (to 0) - no need (already in bss) */
  /*
  register int i;
  for (i = 0; i < 4; i++) {
    handlers_ca1[i].func = 0;
    handlers_timer1[i].func = 0;
  }
  */

  /* add a new (init) process */
  newproc(&systemd);
  /* switch to init process (pid=0) with no return */
  swtchin(&processes[0].ppda[0]);
}


/*
void puts(char * s) {
  while (*s) {
    switch (*s) {
      case '\n':
        lcd_instruction(0xc0); // set cursor address to 0x40
        s++;
        break;
      default:
        putc(*s++);
    }
  }
}

void do_pause(char * s) {
  lcd_instruction(0x01);
  puts(s);
  pause();
}
*/
