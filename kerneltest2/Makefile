
all: always-submake main.bin

PGMS=$(wildcard user/%.pgm/)
BINS=$(patsubst %.pgm/,%.pgm/out.bin,$(PGMS))

always-submake:
	make -C user/ $(BINS)

VASM=vasm
VLINK=vlink
VBCC=vbcc
LD_SCRIPT=../emu.ld
TMP_VBCC_ASM=/tmp/tmp_vbcc_asm.s

VASM_FLAGS=-wdc02 -esc -I"../"
VLINK_FLAGS=-Mlisting.txt
# 1+2+4+8+16+256=287
VCC_FLAGS=-c02 -O=287
VCA_FLAGS=-wdc02 -opt-branch

SRCS=  $(wildcard *.s)
VOBJS= $(patsubst %.s,%.vobj,$(SRCS))
CSRCS= $(wildcard *.c)
VOBJS+=$(patsubst %.c,%.vobj,$(CSRCS))

#FOR SOME REASON USING $(shell ) IS DIFFERENT FROM NORMAL COMMANDS
# (changed files aren't updating)
# AND I HAVE NO CLUE WHYYY

main.bin:  $(VOBJS) $(BINS)
	$(VLINK) $(VLINK_FLAGS) -b rawbin1 -o main.bin  -T $(LD_SCRIPT) $(VOBJS)
	make -C user/ -B init.pgm/out.bin  S_ADDR=$$(printf '%d\n' 0x`sed -n 's/^  0x\([0-9a-f]*\) entry_init.*$$/\1/p' < listing.txt`)
	make -C user/ -B test.pgm/out.bin  S_ADDR=$$(printf '%d\n' 0x`sed -n 's/^  0x\([0-9a-f]*\) entry_test.*$$/\1/p' < listing.txt`)
	make -B main.vobj
	$(VLINK) $(VLINK_FLAGS) -b rawbin1 -o main.bin  -T $(LD_SCRIPT) $(VOBJS)


%.vobj: %.s
	$(VASM) $(VASM_FLAGS) $< -Fvobj -o $@

%.vobj: %.c
	$(VBCC) $(VCC_FLAGS) $< -o=$(TMP_VBCC_ASM)
	printf "\n\tinclude ../cregs.s\n" >> $(TMP_VBCC_ASM)
	$(VASM) $(VCA_FLAGS) $(TMP_VBCC_ASM) -Fvobj -o $@

clean:
	rm -f *.vobj $(TMP_VBCC_ASM) main.bin
	make -C user/ clean
dump: main.bin
	cat listing.txt | grep -v ": local abs" | ack --color-match=red --passthru "0x.... [_a-zA-Z0-9]*: global .*"
