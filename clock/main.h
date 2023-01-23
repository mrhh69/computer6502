
#ifndef MAIN_H
#define MAIN_H
// from main.s

extern void timer2_loop();
extern __reg("a") unsigned char rtcton(__reg("a") unsigned char r);

#endif
