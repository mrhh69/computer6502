
all: always-submake main.bin

always-submake:
	make -C user/ out.bin S_ADDR=0

VASM=vasm
VLINK=vlink
VBCC=vbcc
LD_SCRIPT=../emu.ld
TMP_VBCC_ASM=/tmp/tmp_vbcc_asm.s

VASM_FLAGS=-wdc02 -I"../"
VLINK_FLAGS=-Mlisting.txt
# 1+2+4+8+16+32+128+256
VCC_FLAGS=-c02 -O=447
VCA_FLAGS=-wdc02 -opt-branch

SRCS=  $(wildcard *.s)
VOBJS= $(patsubst %.s,%.vobj,$(SRCS))
CSRCS= $(wildcard *.c)
VOBJS+=$(patsubst %.c,%.vobj,$(CSRCS))

#FOR SOME REASON USING $(shell ) IS DIFFERENT FROM NORMAL COMMANDS
# (changed files aren't updating)
# AND I HAVE NO CLUE WHYYY

main.bin:  $(VOBJS) user/out.bin
	$(VLINK) $(VLINK_FLAGS) -b rawbin1 -o main.bin  -T $(LD_SCRIPT) $(VOBJS)
	#$$(printf '%d\n' 0x`sed -n 's/^  0x\([0-9a-f]*\) entry_user.*$$/\1/p' < listing.txt`)
	#$(shell printf '%d\n' 0x$(shell sed -n 's/^  0x\([0-9a-f]*\) entry_user.*$$/\1/p' < listing.txt))
	make -C user/ -B out.bin  S_ADDR=$$(printf '%d\n' 0x`sed -n 's/^  0x\([0-9a-f]*\) entry_user.*$$/\1/p' < listing.txt`)
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
