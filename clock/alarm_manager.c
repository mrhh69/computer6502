#include "i2c_lib/rtc.h"
#include "lcd_lib/lcd.h"
#include "alarm_manager.h"


#define ALARM_RTC_ADDR 0x10
#define ALARM_RTC_LEN  0x03

#define ALARM_HERE    0x80  // flags marks valid alarm data
#define ALARM_ACTIVE  0x40  // is alarm enabled?

static struct alarm {
  unsigned char flags;   // alarm flags
  unsigned char hours;   // hours (not RTC format)
  unsigned char minutes; // minutes
  //unsigned char pad;
} alarm;
static const struct alarm alarm_default;

#define FIELD_HOURS    0
#define FIELD_MINUTES  1
#define FIELD_ENABLE   2
static unsigned char field;
static unsigned char field_val;

static const char alarm_active[4] = "ON ";
static const char alarm_inactive[4] = "OFF";

#define MAX_COUNTS 4
#define B_COUNTS 2
static unsigned char counts;


static void put_blink(unsigned char f, unsigned char r) {
  if (field == f && counts < B_COUNTS) {
    putc(' ');
    putc(' ');
  }
  else {
    putc((r >> 4) + '0');
    putc((r & 0xf) + '0');
  }
}

void alarm_manager_periodic() {
  /* draw alarm to screen, blink current field select */
  unsigned char r;
  lcdins(0x02);
  /* draw (or blink) hours */
  put_blink(FIELD_HOURS, ntortc(alarm.hours));
  putc(':');

  /* draw minutes (field == 1) */
  put_blink(FIELD_MINUTES, ntortc(alarm.hours));

  lcdins(0x80|0x40|0); // move cursor to second line beginning
  if (field == FIELD_ENABLE && counts < B_COUNTS) {
    putc(' ');
    putc(' ');
    putc(' ');
  }
  else {
    if (alarm.flags & ALARM_ACTIVE) {
      putc(alarm_active[0]);
      putc(alarm_active[1]);
      putc(alarm_active[2]);
    }
    else {
      putc(alarm_inactive[0]);
      putc(alarm_inactive[1]);
      putc(alarm_inactive[2]);
    }
  }

  /* update counts */
  counts++;
  if (counts >= MAX_COUNTS) counts = 0;
}

void alarm_manager_button() {
  
}


void alarm_manager_init() {
  /* read alarm from rtc memory */
  rtc_read((char *)&alarm, ALARM_RTC_LEN, ALARM_RTC_ADDR);
  if (!(alarm.flags & ALARM_HERE)) {
    /* if flag is not set (no alarm data present), initialize */
    rtc_write((char *)&alarm_default, ALARM_RTC_LEN, ALARM_RTC_ADDR);
  }
  /* reset LCD screen */
  lcdins(0x01);
}


static const struct alarm alarm_default = {
  ALARM_HERE,   // inactive alarm
  0,            // 0 hours
  0             // 0 minutes
};
