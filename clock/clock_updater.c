#include "lcd_lib/lcd.h"

extern void clock_lcd_periodic();

#define COUNTS 4

volatile unsigned char counts;
volatile unsigned char field = 2;

#define NUM_FIELDS 6

static struct field {
  unsigned char pos;
  unsigned char len;
} fields[NUM_FIELDS] = {
  {     0, 2},
  {     3, 2},
  {     6, 2},
  {0x40|0, 3},
  {0x40|5, 3},
  {0x40|9, 2}
};

void clock_updater_periodic() {
  /* NOTE: calling this and then using the blink effect causes a visual artefact -> fix? */
  clock_lcd_periodic();

  counts++;
  counts &= (COUNTS-1);
  if (counts < (COUNTS/2)) {
    /* do nothing */
  }
  else {
    /* blink */
    if (field > NUM_FIELDS) {return;} // memory safety :)
    lcdins(0x80 | fields[field].pos);
    for (unsigned char i = 0; i < fields[field].len; i++) {
      putc(0xff); // blanking character (0xff -> black)
    }
  }
}
