#include "kernel.h"

/* kernel.s: */
extern void systemd();
//extern void memcpy(char * src, char * dst, unsigned int length);
extern void swtchin(__reg("r0/r1") char * ppda);


union process processes[8];
struct handler handlers_ca1[4];
struct handler handlers_timer1[4];

void update() = "\tbyte $02\n\tbyte $13";
void label() = "\tbyte $22\n\tasciiz \"message\"";

int main() {

  /* add a new (init) process */
  newproc(&systemd);
  /* switch to init process (pid=0) with no return */
  swtchin(&processes[0].ppda[0]);


  //return 0;
}
