

NUM_USER=2


NUM_PROCS=8

; kernel temp registers
kr0=$00
kr1=$02

KSTACK_START = $3f
USTACK_START = $ff

BRK_SWTCH=$01
BRK_FORK =$02
BRK_EXEC =$03
BRK_PUTC =$04

; ppda struct
PPDA_PID=14
PPDA_SP =15
; defaults for ppda
PROC_SP=$2ff
PROC_SR=$20
PROC_SPL=$ce    ; location of SP in user ppda


NUM_STREAMS = 1
LCD_NO = 0
; stream flags
STREAM_LCD   = %10000000

; lcd stream commands
LCD_C_LCDINS = 1
LCD_C_PUTC   = 2
