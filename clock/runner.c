#include "main.h"
#include "clock.h"
#include "clock_updater.h"
#include "alarm_manager.h"


volatile unsigned char mode;

struct mode {
  void (*init)();
  void (*periodic)();
  void (*button_handler)();
  void (*padding)();
  //void (*handlers)()[5];
  /* TODO: void (*handler)(); that will be passed current state of all buttons */
};
#define NUM_MODES 3

#define NULL ((void *)0)
static const struct mode modes[NUM_MODES] = {
  {
    &clock_lcd_init, &clock_lcd_periodic, NULL
  },
  {
    &clock_updater_init, &clock_updater_periodic, &clock_updater_button
  },
  {
    &alarm_manager_init, &alarm_manager_periodic, &alarm_manager_button
  }
};


void do_init() {
  modes[mode].init();
}
void do_periodic() {
  modes[mode].periodic();
}
void do_button_press() {
  if (modes[mode].button_handler) modes[mode].button_handler();
}
