
#ifndef LCD_H
#define LCD_H
// from 4BitLCD.s

extern void putc(__reg("a") char character);
extern void lcdins(__reg("a") unsigned char lcd_instruction);

#endif
