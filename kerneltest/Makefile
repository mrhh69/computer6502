VASM=vasm
VLINK=vlink
VBCC=vbcc

VASM_FLAGS=-wdc02 -esc -opt-branch -x -nosym -I"../"
VLINK_FLAGS=-T ../test.ld -Mlisting.txt
TMP_VBCC_ASM=/tmp/tmp_vbcc_asm.s
VCC_FLAGS=-c02 -O=447
VCA_FLAGS=-wdc02 -opt-branch
CRT=ecrt.s
CSRCS=   test.c kernelc.c
CSRCOUT= $(patsubst %.c,%.s,$(CSRCS))
SRCS=    $(CRT) clib.s kernel.s user.s
SRCS+= $(CSRCOUT)
VOBJS=   $(patsubst %.s,%.vobj,$(SRCS))


VFLAGS=-Fbin
VFLAGS += -dotdir -esc -wdc02

# It turns out o65 is kinda weird (doesn't support named sections)
# TODO: find a way to use shared objects (to link only the routines that are actually used)
# So, instead I'm going to use vobj
test.bin: $(VOBJS)
	$(VLINK) -b rawbin1 -o test.bin  $(VLINK_FLAGS) $(VOBJS)
# Objects:
%.vobj: %.s
	$(VASM) $(VASM_FLAGS) $< -Fvobj -o $@
# c sources:
%.vobj: %.c
	$(VBCC) $(VCC_FLAGS) $< -o=$(TMP_VBCC_ASM)
	printf "\n\tinclude ../cregs.s\n" >> $(TMP_VBCC_ASM)
	$(VASM) $(VCA_FLAGS) $(TMP_VBCC_ASM) -Fvobj -o $@

clean:
	rm *.vobj test.bin

copy: test.bin
	cp test.bin ~/Documents/emu6502/a.out
