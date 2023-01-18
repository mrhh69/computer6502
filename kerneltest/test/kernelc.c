#include "kernel.h"


void update() = "\tbyte $02";
void pause() = "\tbyte $13";

void new_handler_ca1(__reg("r0/r1") void (*func)()) {
  new_handler(func, &handlers_ca1[0]);
}
void new_handler_timer1(__reg("r0/r1") void (*func)()) {
  new_handler(func, &handlers_timer1[0]);
}

void new_handler(__reg("r0/r1") void (*func)(), struct handler *handlers) {
  register unsigned char i;
  for (i = 0; i < 4; i++) {
    if (!handlers[i].func) {
      handlers[i].func = func;
      return;
    }
  }
}
void call_handlers(__reg("r0/r1") struct handler *handlers) {
  register unsigned char i;
  update(); pause();
  for (i = 0; i < 4; i++) {
    if (handlers[i].func) {
      (*handlers[i].func)();
    }
  }
}
