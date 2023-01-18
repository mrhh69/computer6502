VASM=vasm
VLINK=vlink
VBCC=vbcc

VASM_FLAGS=-wdc02 -esc -x -nosym -I"../"
VLINK_FLAGS=-Mlisting.txt
VLINKER=../test.ld
SRCS=    ebug.s
VOBJS=   $(patsubst %.s,%.vobj,$(SRCS))


VFLAGS=-Fbin
VFLAGS += -dotdir -esc -wdc02

# It turns out o65 is kinda weird (doesn't support named sections)
# TODO: find a way to use shared objects (to link only the routines that are actually used)
# So, instead I'm going to use vobj
main.bin: $(VOBJS)
	$(VLINK) -b rawbin1 -o main.bin  $(VLINK_FLAGS) -T $(VLINKER)   $(VOBJS)
# Objects:
%.vobj: %.s
	$(VASM) $(VASM_FLAGS) $< -Fvobj -o $@

clean:
	rm *.vobj main.bin debug

copy: main.bin
	cp main.bin ~/Documents/computer6502/a.out

debug: debug.c
	clang debug.c -o debug
