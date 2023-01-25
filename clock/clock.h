
#ifndef CLOCK_H
#define CLOCK_H

/* TODO: move or rename buf or SOMETHING because this is terrible */
extern char buf[8];

void clock_lcd_print();
void clock_lcd_init();
void clock_lcd_periodic();


#endif
