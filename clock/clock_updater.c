#include "lcd_lib/lcd.h"
#include "i2c_lib/rtc.h"
#include "clock.h"
#include "clock_updater.h"

#define COUNTS 4
// 0xff -> block of black
#define BLANKING_CHAR ' ' // character that blinks current field

static volatile unsigned char counts;
// field = (field + 1) % (NUM_FIELDS + 1)
static volatile unsigned char field = 2; // NUM_FIELDS -> no field
static volatile unsigned char field_val;

#define NUM_FIELDS 6

static const struct field {
  unsigned char rtc; // mem pos in rtc
  unsigned char pos; // pos on lcd (when printed)
  unsigned char len; // len on lcd (when printed)
  unsigned char pad;
} fields[NUM_FIELDS] = {
  {2,      0, 2}, // hours
  {1,      3, 2}, // minutes
  {0,      6, 2}, // seconds
  {3, 0x40|0, 3}, // DOTW
  {5, 0x40|5, 3}, // month
  {4, 0x40|9, 2}  // DOTM
};

void clock_updater_periodic() {
  /* NOTE: calling this and then using the blink effect causes a visual artefact -> fix? */
  rtc_read(buf, 7, 0);
  /* update with field_val */
  unsigned char field_b = fields[field].rtc;
  if (field < NUM_FIELDS) {
    if (buf[field_b] != field_val) {
      /* update, and push changes to RTC */
      buf[field_b] = field_val;
      //rtc_write(&buf[field_b], 1, field_b);
    }
  }

  clock_lcd_print();

  counts++;
  counts &= (COUNTS-1);
  if (counts < (COUNTS/2)) {
    /* do nothing */
  }
  else {
    /* blink */
    if (field >= NUM_FIELDS) {return;} // memory safety :)
    lcdins(0x80 | fields[field].pos);
    for (unsigned char i = 0; i < fields[field].len; i++) {
      putc(BLANKING_CHAR);
    }
  }
}

void clock_updater_init() {
  if (field >= NUM_FIELDS) return;
  rtc_read(buf, 1, fields[field].rtc);
  field_val = buf[0];
}
