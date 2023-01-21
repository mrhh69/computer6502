


#ifndef KERNEL_H
#define KERNEL_H


struct handler {
  void (*func)();
};

// pad to 8b
extern struct process {
  unsigned char pri;
  unsigned char flags; /* non-zero if the process slot is being used */
  struct handler handler_ca1;
  struct handler handler_timer1;
  /* maybe keep a pointer to ppda?
   * I mean, the [bad] way I have it set up rn means it isn't necessary
   * But could be helpful in the better, dynamically memory allocated future!
   */
  char padding[2];
} processes[8];

extern union data {
  /* NOTE: this is what is copied into the zero/stack page */
  struct {
    unsigned char pid;
    unsigned char sp;
  } proc;
  unsigned char ppda[512];
} processes_data[8];

/* NOTE: passed through r0/r1 because it won't seem to actually save a/x when I specify it :( */

__reg("a/x") char * get_swtch();
void newproc(__reg("a/x") void (*entry)());

#endif
