


#ifndef KERNEL_H
#define KERNEL_H


extern union process {
  struct proc {
    unsigned char sp;
    unsigned char pid;
    unsigned char pri;
    unsigned char flags; /* non-zero if the process slot is being used */
  } proc;
  unsigned char ppda[512];
} processes[8];


struct handler {
  void (*func)();
};
extern struct handler handlers_ca1[4];
extern struct handler handlers_timer1[4];

/* NOTE: passed through r0/r1 because it won't seem to actually save a/x when I specify it :( */
void new_handler  (__reg("r0/r1") void (*func)(), struct handler *handlers);
//void call_handlers(__reg("r0/r1") struct handler *handlers);

__reg("a/x") char * get_swtch();
void newproc(__reg("a/x") void (*entry)());

#endif
