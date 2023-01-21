#include "kernel.h"


//void update() = "\tbyte $02";
//void pause() = "\tbyte $13";
void stp() = "stp";
extern void putc(__reg("a") char c);

void new_handler_ca1(__reg("r0/r1") void (*func)()) {
  //new_handler(func, &handlers_ca1[0]);
}
void new_handler_timer1(__reg("r0/r1") void (*func)()) {
  //new_handler(func, &handlers_timer1[0]);
}




__reg("a/x") char * get_swtch() {
  /* NOTE: maybe fix the fact that this uses the stack in the future (as it would be using the current user process's stack, which isn't inherently terrible, I guess, but still not great): */
  register unsigned char i, lowpri = 0xff;
  int best = 0;

  for (i = 0; i < 8; i++) {
    if (processes[i].flags) {
      if (!best) {best = i; continue;}
      if (processes[best].pri > processes[i].pri) best = i;
      if (processes[best].pri < lowpri) lowpri = processes[best].pri;
    }
  }
  if (lowpri) {
    for (i = 0; i < 8; i++) {
      if (processes[i].flags) {
        processes[i].pri -= lowpri;
      }
    }
  }

  return &processes_data[best].ppda[0];
}

void newproc(__reg("a/x") void (*entry)()) {
  unsigned char * ptr;
  for (unsigned char i = 0; i < 8; i++) {
    if (!processes[i].flags) {
      processes[i].pri = 0;
      processes[i].flags = 1;
      processes_data[i].ppda[0x40] = 0;   // stack pointer to point at 0x4000
      processes_data[i].ppda[0x41] = 0x40;
      processes_data[i].proc.pid = i + 1;

      processes_data[i].proc.sp = 0xf9;
      ptr = &processes_data[i].ppda[256 + 0xfa];
      *(void (**)())(ptr + 4) = entry; // pc
      *(char *)(ptr + 3) =  0x20; // status (NV1BDIZC) -> interrupts enabled, decimal mode disabled
      // 0-a, 1-x, 2-y (uninitialized)
      return;
    }
  }
}
