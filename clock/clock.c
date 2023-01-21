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


int main() {
  lcdins(0x01); // reset
  putc('h'); // hello world

  return 0;
  /* first, rtc_read to make sure clock is running */
  /* if not, then re-write rtc defaults */

  for (;;) {
    /* rtc_read into a buffer */
    /* print data onto lcd using putc and lcdins */
  }

  //return 0;
}
