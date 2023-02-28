#include <stdio.h>
#include <stdint.h>
#include <unistd.h>
#include <stdlib.h>
#include <time.h>
#include <signal.h>
#include <termios.h>

#define UPDATE 0x02
#define JAM 0x03
#define PAUSE 0x13
#define DISPLAY 0x22
#define CLOCK_SET 0x23
#define CLOCK_STOP 0x33
#define CLOCK_PAUSE 0x42
#define PUT_C 0x43

uint8_t rom[32768];
uint8_t ram[32768];
#define FILL 0xea


extern int vpb;
extern uint16_t pc;
extern uint8_t sp, a, x, y, status;

extern uint32_t instructions; //keep track of total instructions executed
extern uint32_t clockticks6502, clockgoal6502;
extern uint16_t oldpc, ea, reladdr, value, result;
extern uint8_t opcode, oldstatus;


extern void reset6502();
extern void irq6502();
extern void step6502();


uint8_t portA = 0;
uint8_t portB = 0;
uint8_t ifr = 0;

#define USER 0x1
#define SWR  0x2
#define C_INT 0x1


int b(int a, int i) {return (a >> i) & 1;}

int nand(int a, int b) {return !(a && b);}
int or(int a, int b) {return (a || b);}
int nor(int a, int b) {return !or(a, b);}

int viasb(int a, int k) {
  return (
    or(
        or(nand(nand(k, k), b(a, 15)),
          or(b(a, 14), b(a, 13))),
        or(or(b(a, 12), b(a, 11)),
          b(a, 10))
    )
    );
}

int romsb(int a, int vb) {
  return nand(vb, b(a, 15));
}

int ramsb(int a, int k) {
  return nor(
    nor(or(b(a, 15), b(a, 14)),
      or(b(a, 13), b(a, 12))),
    nor(b(a, 15), k)
  );
}


uint8_t read6502(uint16_t address) {
  int vb = viasb(address, portA & USER);
  int romb = romsb(address, vb);
  int ramb = ramsb(address, portA & USER);

  if (!ramb) return ram[address & 0x7fff];
  if (!romb) return rom[address & 0x7fff];
  if (!vb) {
    uint8_t l = address & 0xf;
    if (l == 0) return portA;
    if (l == 1) return portB;
    if (l == 2) return ifr;
  }
  return 0;
}

void write6502(uint16_t address, uint8_t value) {
  int vb = viasb(address, portA & USER);
  int romb = romsb(address, vb);
  int ramb = ramsb(address, portA & USER);

  if (!ramb) ram[address & 0x7fff] = value;
  if (!romb);
  if (!vb) {
    uint8_t l = address & 0xf;
    if (l == 0) portA = value;
    if (l == 1) portB = value;
    if (l == 2) ifr = value;
  }
}


void init(char * inf) {
  FILE * inFile = fopen(inf, "rb");
  for (uint16_t i = 0; i < 32768; i++) ram[i] = 0;
  for (uint16_t i = 0; i < 32768; i++) rom[i] = (uint8_t)fgetc(inFile);
  fclose(inFile);
}

/*
void updateM() {
  FILE * outFile = fopen("mem.txt", "w");

  for (uint16_t i = 0; (i + 1) & 0xffff; i++) {
    if ((i % 16) == 0) {fprintf(outFile, "\n%04x: ", i);}
    fprintf(outFile, "%02x, ", read6502(i));
  }

  fclose(outFile);
}
*/

extern void commands();
void print_internals() {
  printf("|%02x %02x %02x %02x|%02x PC:%04x  USER:%01i\n",
    a, x, y, sp, status, pc,
    portA & USER);
}



int main(int argc, char * argv[]) {
  char * infile = argc > 1 ? argv[1] : "a.out";
  init(infile);
  printf("Loaded Memory from '%s'\n\n", infile);

  //updateM();

  reset6502();

  unsigned int lw = 0;
  unsigned int clockWait = 0;
  int clockRun = 0;


  while (1) {
    if (vpb) portA &= ~USER;
    if (read6502(pc) == JAM) break;
    if (read6502(pc) == UPDATE) {
      printf("|%02x %02x %02x %02x|%02x PC:%04x  T:%i  CR:%01i CS: %i    USER:%01i\n",
        a, x, y, sp, status, pc, clockticks6502 - lw, clockRun, clockWait,
        portA & USER);
      lw = clockticks6502;
      //updateM();
      pc++; continue;
    }
    if (read6502(pc) == PAUSE) {
      commands();
      pc++; continue;
    }
    if (read6502(pc) == DISPLAY) {
      printf("  ");
      while (read6502(pc) != 0) printf("%c", read6502(++pc));
      printf("\n");
      pc++; continue;
    }

    if (read6502(pc) == CLOCK_SET) {
      clockRun = 1;
      pc++; continue;
    }
    if (read6502(pc) == CLOCK_STOP) {
      clockRun = 0;
      clockWait = 0;
      pc++; continue;
    }
    if (read6502(pc) == CLOCK_PAUSE) {
      clockRun = 0;
      pc++; continue;
    }
    if (read6502(pc) == PUT_C) {
      printf("%c", a);
      pc++; continue;
    }
    if (read6502(pc) == 0x44) {
      exit(a);
    }

    step6502();

    if (clockRun) {
      clockWait++;
      if ((clockWait >= 256) && !(status & 0x04)) {
        clockWait = 0; clockRun = 0;
        printf("\t\tClockInterrupt!!\n"); ifr |= C_INT; irq6502();
      }
    }
    fflush(stdout);
  }

  printf("\n");
  return 0;
}
