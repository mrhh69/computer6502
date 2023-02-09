#include "lcd_lib/lcd.h"
#include "i2c_lib/rtc.h"
#include "main.h"
#include "rtc_buf.h"

#define RTC_DEFAULT_LEN 8

static const char rtc_defaults[RTC_DEFAULT_LEN];

/* making it a char [12][3] seems to make vbcc use __mulint8
 * this is because of byte-alignment, i guess vbcc doesn't
 * do byte-alignment automatically
 */
static const char month_names[12][4];
static const char dotw_names[12][4];

char buf[8];


void clock_lcd_print() {
  unsigned char ind;
  /* NOTE:
   * not LCD reset, because quickly clearing and
   * setting the LCD screen causes wierd visual effects)
   */
  lcdins(0x02); // LCD return cursor to 0
  putc('0' + ((buf[2] >> 4) & 0xf));
  putc('0' + (buf[2] & 0xf));
  putc(':');
  putc('0' + ((buf[1] >> 4) & 0xf));
  putc('0' + (buf[1] & 0xf));
  putc(':');
  putc('0' + ((buf[0] >> 4) & 0x7));
  putc('0' + (buf[0] & 0xf));
  putc(buf[0] & 0x80 ? 'S' : ' ');

  lcdins(0x80 | 0x40); // set cursor start of line 2
  ind = rtcton(buf[3]) - 1; /* NOTE: rtcton probably not necessary, dotw shouldn't be > 7 */
  if (ind >= 7) return; /* invalid DOTW, prevent memory unsafety */
  putc(dotw_names[ind][0]);
  putc(dotw_names[ind][1]);
  putc(dotw_names[ind][2]);
  putc(',');
  putc(' ');

  ind = rtcton(buf[5]) - 1;
  if (ind >= 12) return; /* invalid month, probably RTC bus failure or smth */
  putc(month_names[ind][0]);
  putc(month_names[ind][1]);
  putc(month_names[ind][2]);
  putc(' ');
  if (buf[4] & 0x70) putc('0' + ((buf[4] >> 4) & 0x7));
  else putc(' ');
  putc('0' + (buf[4] & 0xf));
}

void clock_lcd_periodic() {
  /* rtc_read into a buffer */
  rtc_buf_read(buf, 7, 0);
  /* print data onto lcd using putc and lcdins */
  clock_lcd_print();
}

void clock_lcd_init() {
  /* first, rtc_read to make sure clock is running */
  rtc_buf_read(buf, 8, 0);

  rtc_buf_write((char *)rtc_defaults, RTC_DEFAULT_LEN, 0);

  if (buf[0] & 0x80) {
    /* if not, then re-write rtc defaults */
    //rtc_buf_write((char *)rtc_defaults, RTC_DEFAULT_LEN, 0);
  }
  else if (buf[7] != rtc_defaults[7]) {
    /* rewrite control register separately */
    //rtc_buf_write((char *)&rtc_defaults[7], 1, 7);
  }

  rtc_buf_flush();

  lcdins(0x01); // reset lcd
}

static const char rtc_defaults[RTC_DEFAULT_LEN] = {
  /* NOTE: these numbers are in the format of 0b0hhhllll
   * h -> the first digit of the decimal value
   * l ->  the last digit of the decimal value
   * So, 0x15 == 1 and 5 (or 15 decimal)
   */
  0x00, // Seconds (top bit is CH, clock halt)
  0x00, // Minutes
  0x22, // Hours (bit 6 high is 12-hour mode select)
  0x01, // Day of the week?
  0x23, // Day of the month
  0x01, // month
  0x23, // year
  0x13, // control register (OUT 0 0 SQWE 0 0 RS1 RS0)
};

static const char month_names[12][4] = {
  "jan",
  "feb",
  "mar",
  "apr",
  "may",
  "jun",
  "jul",
  "aug",
  "sep",
  "oct",
  "nov",
  "dec"
};
static const char dotw_names[12][4] = {
  "mon",
  "tue",
  "wed",
  "thu",
  "fri",
  "sat",
  "sun"
};
