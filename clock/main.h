
#ifndef MAIN_H
#define MAIN_H

// button defs
#define BUTTON_UP    0x1
#define BUTTON_DOWN  0x2
#define BUTTON_LEFT  0x4
#define BUTTON_RIGHT 0x8

// from main.s
extern volatile unsigned char button_states;
extern volatile unsigned char prev_states;

extern void timer2_loop();
extern __reg("a") unsigned char rtcton(__reg("a") unsigned char r);

#endif
