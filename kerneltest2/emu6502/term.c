#include <stdio.h>
#include <stdint.h>
#include <unistd.h>
#include <termios.h>
#include <sys/ioctl.h>


#define clear() printf("\033[H\033[J")
#define gotoxy(x,y) printf("\033[%d;%dH", (y), (x))


extern uint8_t read6502(uint16_t address);
extern void print_internals();


void do_show(uint16_t addr, char (*getaddr)(uint16_t)) {
	struct winsize w;
  ioctl(STDOUT_FILENO, TIOCGWINSZ, &w);
	for (int i = 0; i < w.ws_row; i++) printf("\n");
	//clear();
	gotoxy(0,0);


  static struct termios oldt, newt;
  /*tcgetattr gets the parameters of the current terminal
  STDIN_FILENO will tell tcgetattr that it should write the settings
  of stdin to oldt*/
  tcgetattr( STDIN_FILENO, &oldt);
  /*now the settings will be copied*/
  newt = oldt;
  /*ICANON normally takes care that one line at a time will be processed
  that means it will return if it sees a "\n" or an EOF or an EOL*/
  newt.c_lflag &= ~(ICANON);
  /*Those new settings will be set to STDIN
  TCSANOW tells tcsetattr to change attributes immediately. */
  tcsetattr( STDIN_FILENO, TCSANOW, &newt);

  /*This is your part:
  I choose 'e' to end input. Notice that EOF is also turned off
  in the non-canonical mode*/
	char c, p = 0;
  while((c=getchar())!= 'e') {
		/* get key inputs */
		if (p == '[' && c == 'A') /* up    */ addr = addr - 16 < 0 ? 0 : addr - 16;
		if (p == '[' && c == 'B') /* down  */ addr = addr + 16 > 0xffff ? 0xffff : addr + 16;
		if (p == '[' && c == 'C') /* right */ addr = addr + 1  > 0xffff ? 0xffff : addr + 1;
		if (p == '[' && c == 'D') /* left  */ addr = addr - 1  < 0 ? 0 : addr - 1;
		p = c;

		/* go back to 0 */
		/* NOTE: this is causing screen tearing issues: fix by drawing over? */
		clear();
		for (int i = 0; i < w.ws_row - 1; i++) printf("\n");
		gotoxy(0,0);

		/* update screen thing */
		int rows = w.ws_row - 2;
		uint16_t a = (addr & ~0xf) - (16 * rows / 2);
		for (int i = 0; i < rows; i++) {
			/* row */
			if (a == (addr & ~0xf)) printf("\033[1m");
			printf("%04x: ", a);
			printf("\033[0m");
			for (int b = 0; b < 16; b++) {
				if (a + b == addr) printf("\033[32m");
				printf("%02x ", (unsigned char)getaddr(a + b));
				printf("\033[0m");
			}
			a += 16;
			if (i < rows - 1) printf("\n");
		}
	}

  /*restore the old settings*/
  tcsetattr( STDIN_FILENO, TCSANOW, &oldt);

	clear();
}


char geta(uint16_t a) {
	return 0;
}

void commands() {
	for (;;) {
		printf("paused>");
		char buf[256];
		char *c = &buf[0];
		while ((*c++ = getchar()) != '\n');
		*(c) = 0;


		unsigned int a;

		switch (buf[0]) {
			/* dump registers */
			case 'd':
				print_internals();
				break;

			/* show address */
			/* sXXXX (XXXX address in hex) */
			case 's':
				sscanf(buf, "s%04x", &a);
				printf("show address %04x\n", a);

				do_show((uint16_t)a, (char (*)(uint16_t))&read6502);
				break;

			/* end commands: */
			case '\n':
			case 'e':
			case 'c':
				//printf("continuing...\n");
				return;
		}
	}
}

/*
int main() {
	commands();
	return 0;
}
*/
