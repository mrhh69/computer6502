
#define PORTB  ((char *)0x6000)
#define PORTA  ((char *)0x6001)
#define DDRB   ((char *)0x6002)
#define DDRA   ((char *)0x6003)
#define ACR    ((char *)0x600B)
#define PCR    ((char *)0x600C) /* CA,CB Control (interrupt lines) */
#define IFR    ((char *)0x600D) /* Interrupt Flags Register */
#define IER    ((char *)0x600E) /* Interrupt Enable Register */

/* clib.s: */
extern void lcd_init(char cursor_on, char cursor_blink); /* (int, but only the lower byte is used) */
extern void lcd_instruction(unsigned char instruction);
extern void putc(char c);
extern void pause();

void puts(char * s) {
  while (*s) {
    switch (*s) {
      case '\n':
        lcd_instruction(0xc0); /* set cursor address to 0x40 */
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

int main() {
  /* initialize VIA 6522 */
  *DDRA = *DDRB = 0xff;
  *PORTA = 0xaa;
  *ACR = 0x00; /* timer1 one-shot interrupt after loaded */
  *PCR = 0x01; /* ca1 enabled */
  *IER = 0xc2; /* Interrupts: timer1 enabled, ca1 enabled */
  *IFR = 0;    /* reset flags to null */

  lcd_init(1, 0);
  //puts("Hello, C world!\nTime 2 Hack");

  do_pause("Paused!");
  puts("\nAnd unpaused!");

  return 0;
}
