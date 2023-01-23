#include "main.h"
#include "i2c_lib/rtc.h"
#include "lcd_lib/lcd.h"


#define RTC_DEFAULT_LEN 8

const char rtc_defaults[RTC_DEFAULT_LEN] = {
  /* NOTE: these numbers are in the format of 0b0hhhllll
   * h -> the first digit of the decimal value
   * l ->  the last digit of the decimal value
   * So, 0x15 == 1 and 5 (or 15 decimal)
   */
  0x02, // Seconds (top bit is CH, clock halt)
  0x15, // Minutes
  0x18, // Hours (bit 6 high is 12-hour mode select)
  0x01, // Day of the week?
  0x23, // Day of the month
  0x01, // month
  0x23, // year
  0x13, // control register (OUT 0 0 SQWE 0 0 RS1 RS0)
};

const char* month_names[12] = {
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

static char buf[8];


void update_lcd_clock() {
  /* rtc_read into a buffer */
  rtc_read(buf, 7, 0);
  /* print data onto lcd using putc and lcdins */
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
  unsigned char month = rtcton(buf[5]) - 1;//((buf[5] >> 4) * 10) + (buf[5] & 0x0f) - 1;
  if (month >= 12) {
    /* invalid month, probably RTC bus failure or smth */
    return;
  }
  else {
    putc(month_names[month][0]);
    putc(month_names[month][1]);
    putc(month_names[month][2]);
  }
  putc(' ');
  if (buf[4] & 0x70) putc('0' + ((buf[4] >> 4) & 0x7));
  putc('0' + (buf[4] & 0xf));
}

int main() {
  char c;
  /* first, rtc_read to make sure clock is running */
  rtc_read(buf, 8, 0);
  if (buf[0] & 0x80) {
    /* if not, then re-write rtc defaults */
    rtc_write((char *)rtc_defaults, RTC_DEFAULT_LEN, 0);
  }
  if (buf[7] != rtc_defaults[7]) {
    /* rewrite control register separately */
    rtc_write((char *)&rtc_defaults[7], 1, 7);
  }

  lcdins(0x01); // reset lcd

  /* enter loop */
  timer2_loop();
  /*
  for (;;) {
    update_lcd_clock();
  }
  */
}
