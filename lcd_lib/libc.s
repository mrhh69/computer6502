

; must be linked with lcd.s
  extern print_char
  extern lcd_instruction
; Wrapper functions (for lcd)
  global _putc
  global _lcdins

  section text
; __reg("a") char character
_putc:
  jsr print_char
  rts
; __reg("a") char instruction
_lcdins:
  jsr lcd_instruction
  rts
