#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <errno.h>

#define ARD_PORT "/dev/cu.usbserial-AB0N0DD8"

#define CMD_REG 2
#define CMD_CONT 3
#define CMD_READ 4



void rb(FILE * f, unsigned char * buf, uint16_t pos, uint16_t len);


int main() {
  FILE * f;
  /* NOTE: "rw" is NOT a mode, "r+" IS */
  if ((f = fopen(ARD_PORT, "r+")) == NULL) {printf("fopen: %i\n", errno); exit(1);}

  sleep(2);

  unsigned char c;
  for (;;) {
    c = fgetc(f);
    printf("got: %i\n", c);
    if (c == 1) {
      fputc(1, f);
      c = fgetc(f);
      printf("Paused! ready to debug: %i\n", c);

      for (;;) {
        printf("\nard>");
        char inbuf[256];
        int i = 0;
        while ((c = getchar()) != '\n') inbuf[i++] = c;
        inbuf[i] = 0;

        unsigned char a, x, y, ps, sp;

        if (strcmp(&inbuf[0], "regs") == 0) {
          /* registers */
          fputc(CMD_REG, f);
          a = fgetc(f);
          x = fgetc(f);
          y = fgetc(f);
          ps = fgetc(f);
          sp = fgetc(f);
          printf("|%02x %02x %02x|%02x|%02x\n", a, x, y, sp, ps);
        }
        else if (inbuf[0] == 'c') {
          /* continue: */
          fputc(CMD_CONT, f);
          goto outcmd;
        }
        else if (inbuf[0] == 'b') {
          for (int i = 0; i < 10; i++) {
            int l = 8;
            unsigned char d[l];
            rb(f, &d[0], 0x1f0 + i * 8, l);
            for (int i = 0; i < l; i++) printf("%02x ", d[i]);
            printf("\n");
            sleep(1);
          }
        }
        else {
          printf("unkown command!");
        }
      }
    }
outcmd:
    continue;
  }

  return 0;
}


void rb(FILE * f, unsigned char * buf, uint16_t pos, uint16_t len) {
  for (int i = 0; i < len; i++) {
    fputc(CMD_READ, f);
    fputc((pos + i) & 0xff, f);
    fputc((pos + i) >> 8, f);
    buf[i] = fgetc(f);
  }
}
