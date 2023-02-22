#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <fcntl.h>
#include <unistd.h>
#include <time.h>



#define TRY1 "/dev/cu.usbmodem101"
#define TRY2 "/dev/cu.usbmodem1101"
#define STTY "/bin/stty"
#define BAUD_STR "115200"

#define FILE_WRITE_SIZE 64*512

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
#define SYNC 8
#define SYNC_BYTE 0x69

void sync() {
  unsigned char c;
  put(SYNC);
  if ((c = get()) != SYNC_BYTE) {
    printf("illegal sync byte! (0x%02x) exiting...\n", c);
    exit(1);
  }
}
void ardread(uint16_t addr, uint16_t len, char *buf) {
  put(SADDR); puti(addr);
  put(SLEN); puti(len);

  put(READ);
  for (uint16_t i = 0; i < len; i++) {
    buf[i] = get();
  }
}
void ardwrite(int addr, int len, char * buf) {
  put(SADDR); puti(addr);
  put(SLEN); puti(len);

  put(WRITE);
  for (int i = 0; i < len; i++) {
    put(buf[i]);
  }
  /* this sync is necessary, idk why */
  sync();
}
void ardpagewrite(int addr, char * buf) {
  if (addr & (64-1)) {printf("page write address not 64-byte aligned!!\n"); exit(1);}

  put(SADDR); puti(addr);
  put(PAGE_WRITE);
  for (int i = 0; i < 64; i++) {
    put(buf[i]);
  }
}


/* len aligned to 64 */
void filewrite(char * f, int pos, int seek, int len) {
  char c;
  FILE * in;
  int b, dirty, db;

  if (!(in = fopen(f, "rb"))) {printf("(filewrite) fopen: %i\n", errno); exit(1);}

  fseek(in, seek, SEEK_SET);

  for (int i = 0; i < len / 64; i++) {
    uint16_t addr = pos + i * 64;
    char buf[64], obuf[64];

    ardread(addr, 64, buf);
    dirty = 0;
    for (int j = 0; j < 64; j++) if (buf[j] != (obuf[j] = fgetc(in))) dirty++;
    while (dirty) {
      /* ardwrite to... maybe help EEPROM getting stuck? I have no idea */
      ardwrite(addr, 1, buf);
      printf("%04x:%04x %i\n", addr, addr + 64, dirty);
      ardpagewrite(addr, obuf);
      ardread(addr, 64, buf);
      dirty = 0;
      for (int j = 0; j < 64; j++) if (buf[j] != obuf[j]) dirty++;
      sync();
    }
  }
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





int main(int argc, char * argv[]) {
  char * dev;
  if ((ard = fopen(TRY1, "r+"))) dev = TRY1;
  else {
    printf("fopen: %i\n", errno);
    if ((ard = fopen(TRY2, "r+"))) dev = TRY2;
    else {
      printf("fopen: %i\n", errno); exit(1);
    }
  }
  /* directly after opening arduino tty, set baud rate */
  if (fork());
  else {
    char *argv[] = {STTY, "-f", dev, BAUD_STR, 0};
    execv(STTY, argv);
  }
  char * writef = argc > 1 ? argv[1] : "a.out";

  printf("ready\n");
  printf("%i\n", get());

  put(SDPOFF);

  srand((unsigned int)time(NULL));
  buf[0] = rand() & 0xff;
  buf[1] = buf[0] + 15;


  ardwrite(0, 1, &buf[0]);
  ardwrite(1, 1, &buf[1]);
  ardcheck(0, buf[0]);
  ardcheck(1, buf[1]);

  printf("writing file '%s'...\n", writef);
  clock_t start = time(NULL);
  filewrite (writef, 0, 0, FILE_WRITE_SIZE);
  clock_t end = time(NULL);
  printf("writing done. (took %lus)\n", end - start);

  put(SDPON);

  put(0);
  fclose(ard);

  return 0;
}
