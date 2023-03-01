


#ifndef KERNEL_H
#define KERNEL_H

#define NUM_PROCS 8

extern struct process {
  unsigned char flags; /* non-zero if the process slot is being used */
  /* maybe keep a pointer to ppda?
   * I mean, the [bad] way I have it set up rn means it isn't necessary
   * But could be helpful in the better, dynamically memory allocated future!
   */
  //char padding[1];
} processes[NUM_PROCS];

extern union data {
  /* NOTE: this is what is copied into the zero/stack page */
  struct {
    uint16_t kregs[2];
    unsigned char padding[10];
    unsigned char pid;
    unsigned char sp;
  } proc;
  struct {
    unsigned char zp[256];
    unsigned char stack[256];
    unsigned char mem1[256];
  } ppda;
} processes_data[NUM_PROCS];

#endif
