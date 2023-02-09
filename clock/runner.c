#include "clock.h"
#include "clock_updater.h"


volatile unsigned char mode;

struct mode {
  void (*init)();
  void (*periodic)();
  //void (*handlers)()[5];
  /* TODO: void (*handler)(); that will be passed current state of all buttons */
};
#define NUM_MODES 2

#define NULL ((void *)0)
static const struct mode modes[NUM_MODES] = {
  {
    &clock_lcd_init, &clock_lcd_periodic
  },
  {
    &clock_updater_init, &clock_updater_periodic
  }
};


void do_init() {
  modes[mode].init();
}
void do_periodic() {
  modes[mode].periodic();
}
