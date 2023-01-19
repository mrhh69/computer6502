#include "main.h"

#define RTC_DEFAULT_LEN 8

const char rtc_defaults[RTC_DEFAULT_LEN] = {
  0x02, // Seconds (top bit is CH, clock halt)
  0x15, // Minutes
  0x18, // Hours (bit 6 high is 12-hour mode select)
  0x01, // Day of the week?
  0x15, // Day of the month
  0x01, // month
  0x23, // year
  0x11, // control register (OUT 0 0 SQWE 0 0 RS1 RS0)
};

static char buf[8];

int main() {
  lcdins(0x01); // reset
  putc('h'); // hello world



  /* first, rtc_read to make sure clock is running */
  rtc_read(buf, 8, 0);
  if (buf[0] & 0x80) {
    /* if not, then re-write rtc defaults */
    rtc_write((char *)rtc_defaults, RTC_DEFAULT_LEN, 0);
  }

  lcdins(0x01);
  for (;;) {
    /* rtc_read into a buffer */
    rtc_read(buf, 7, 0);
    /* print data onto lcd using putc and lcdins */
    lcdins(0x02);
    putc('0' + ((buf[2] >> 4) & 0xf));
    putc('0' + (buf[2] & 0xf));
    putc(':');
    putc('0' + ((buf[1] >> 4) & 0xf));
    putc('0' + (buf[1] & 0xf));
    putc(':');
    putc('0' + ((buf[0] >> 4) & 0x7));
    putc('0' + (buf[0] & 0xf));
    putc(buf[0] & 0x80 ? 'S' : ' ');
  }

  //return 0;
}
