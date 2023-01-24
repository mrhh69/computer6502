

#define NULL ((void *)0)

extern void clock_lcd_periodic();
extern void clock_updater_periodic();


volatile unsigned char mode;

struct mode {
  void (*init)();
  void (*periodic)();
  //void (*handlers)()[5];
};
#define NUM_MODES 2

static const struct mode modes[NUM_MODES] = {
  {
    NULL, &clock_lcd_periodic
  },
  {
    NULL, &clock_updater_periodic
  }
};


void do_periodic() {
  modes[mode].periodic();
}
