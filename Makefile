VASM=vasm
VLINK=vlink
VBCC=vbcc

VASM_FLAGS=-wdc02 -esc -opt-branch -nosym
VLINK_FLAGS=-Mlisting.txt
CRT=crt.s
CSRCS=   test.c
CSRCOUT= $(patsubst %.c,%.s,$(CSRCS))
SRCS=    rtc.s
VOBJS=   $(patsubst %.s,%.vobj,$(SRCS))


VFLAGS=-Fbin
VFLAGS += -dotdir -esc -wdc02

# It turns out o65 is kinda weird (doesn't support named sections)
# TODO: find a way to use shared objects (to link only the routines that are actually used)
# So, instead I'm going to use vobj
test.bin: $(VOBJS)
	$(VLINK) -b rawbin1 -o test.bin  $(VLINK_FLAGS) -T test.ld   $(VOBJS)
# Objects:
%.vobj: %.s
	$(VASM) $(VASM_FLAGS) $< -Fvobj -o $@
# c sources:
$(CSRCOUT): %.s: %.c
	$(VBCC) -c02 $< -O=1 -o=$@

clean:
	rm *.vobj test.bin

copy: test.bin
	cp test.bin ~/Documents/emu6502/a.out



run: main #a.out
	./main

# -esc for C-like strings
a.out: TestWrite.s 4BitLCD.s
	$(VASM) $(VFLAGS) TestWrite.s

main: main.c
	gcc main.c -o main
#clean:
#	rm main a.out
