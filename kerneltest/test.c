#include "kernel.h"

/* kernel.s: */
extern void systemd();
//extern void memcpy(char * src, char * dst, unsigned int length);
extern void swtchin(__reg("r0/r1") char * ppda);


struct process processes[8];
union data processes_data[8];

void update() = "\tbyte $02\n\tbyte $13";
void label() = "\tbyte $22\n\tasciiz \"message\"";

int main() {

  /* add a new (init) process */
  newproc(&systemd);
  /* switch to init process (pid=0) with no return */
  swtchin(&processes_data[0].ppda[0]);
}
