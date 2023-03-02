



NUM_PROCS=8

; kernel temp registers
kr0=$00
kr1=$02
kr2=$04

BRK_SWTCH=$01
BRK_FORK =$02
BRK_PUTC =$03

; ppda struct
PPDA_PID=14
PPDA_SP =15
; defaults for ppda
PROC_SP=$2ff
PROC_SR=$20


NUM_STREAMS = 1
LCD_NO = 0