#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <fcntl.h>
#include <unistd.h>
#include <time.h>


#define TRY1 "/dev/cu.usbmodem14101"
#define TRY2 "/dev/cu.usbmodem14201"

#define FILE_WRITE_SIZE 2048

FILE * ard;
int ardfd;
char buf[64];


void put(char c) {fputc(c, ard);}
void puti(int w) {put(w & 0xff); put(w >> 8);}
int get() {return fgetc(ard);}
uint16_t geti() {return get() | (get() << 8);}

#define SDPOFF 1
#define SDPON 2
#define SADDR 3
#define SLEN 4
#define WRITE 5
#define READ 6
#define PAGE_WRITE 7
#define INTERNALS 8


void ardread(int addr, int len) {
  put(SADDR); puti(addr);
  put(SLEN); puti(len);

  put(READ);
  for (int i = 0; i < len; i++) {
    if (!(i % 16)) printf("\n%04x: ", i + addr);
    printf("%02x, ", get());
  }
  printf("\n");
}
void ardcheck(int addr, char value) {
  char g;
  put(SADDR); puti(addr);
  put(SLEN); puti(1);

  put(READ);
  g = get();
  if (g != value) {
    printf("Value at address %04x (%02x) does not match %02x\n", addr, (unsigned char)g, (unsigned char)value); exit(1);
  }
  else printf("Checked against 0x%02x\n", (unsigned char)value);
}

void ardwrite(int addr, int len, char * buf) {
  put(SADDR); puti(addr);
  put(SLEN); puti(len);

  put(WRITE);
  for (int i = 0; i < len; i++) {
    put(buf[i]);
  }
}
void ardpagewrite(int addr, int len, char * buf) {
  put(SADDR); puti(addr);
  put(SLEN); puti(len);

  put(PAGE_WRITE);
  for (int i = 0; i < len; i++) {
    put(buf[i]);
  }
}

void filewrite(char * f, int pos, int seek, int len) {
  char c;
  FILE * in;
  int b, dirty, db;

  if (!(in = fopen(f, "rb"))) {printf("(filewrite) fopen: %i\n", errno); exit(1);}

  fseek(in, seek, SEEK_SET);

  for (int i = 0; i < len; i++) {
    if (!(i % 64)) {
      put(SADDR); puti(pos + i);
      put(SLEN);
      if ((b = len - i) < 64) puti(b);
      else puti(b = 64);

      for (int o = 0; o < b; o++) buf[o] = fgetc(in);

      put(PAGE_WRITE);
    }
    //if (!(i % 0x800)) printf("w: %04x\n", i);
    //printf("%i:%x\n", i, buf[i % 64]);
    put(buf[i % 64]);
  }
}
void fileverify(char * f, int pos, int seek, int len) {
  FILE * in;
  char c, s;

  if (!(in = fopen(f, "rb"))) {printf("(fileverify) fopen: %i\n", errno); exit(1);}

  fseek(in, seek, SEEK_SET);

  put(SADDR); puti(pos);
  put(SLEN); puti(len);

  put(READ);
  for (int i = 0; i < len; i++) {
    if ((c = get()) != (s = fgetc(in))) {
      printf("bad: %04x (%02x); good: %02x\n", i + pos, (unsigned char)c, (unsigned char)s);
    }
  }
  printf("verified file '%s' (%04x:%04x)\n", f, pos, pos + len);
}

int main(int argc, char * argv[]) {
  time_t t;
  if ((ard = fopen(TRY1, "r+")));
  else {
    printf("fopen: %i\n", errno);
    if ((ard = fopen(TRY2, "r+")));
    else {
      printf("fopen: %i\n", errno); exit(1);
    }
  }
  char * writef = argc > 1 ? argv[1] : "a.out";

  //sleep(2);
  printf("ready\n");
  printf("%i\n", get());

  put(SDPOFF);

  srand((unsigned int)time(&t));
  buf[0] = rand() & 0xff;
  buf[1] = buf[0] + 15;
  ardwrite(0, 1, &buf[0]);
  ardwrite(1, 1, &buf[1]);
  ardcheck(0, buf[0]);
  ardcheck(1, buf[1]);

  printf("writing file '%s'...\n", writef);
  filewrite (writef, 0, 0, FILE_WRITE_SIZE);
  fileverify(writef, 0, 0, FILE_WRITE_SIZE);

  filewrite (writef, 0x7ffa, 0x7ffa, 6);
  fileverify(writef, 0x7ffa, 0x7ffa, 6);

  put(SDPON);
  put(0);


  fclose(ard);

  return 0;
}
