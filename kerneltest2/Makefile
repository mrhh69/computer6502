

all: always-submake main.bin

#always-submake so that the make is called even when the object is already built,
#to check for any change in the source files (which can only be done from sub-make)
always-submake:



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


main.bin:  $(VOBJS)
	$(VLINK) $(VLINK_FLAGS) -b rawbin1 -o main.bin  -T $(LD_SCRIPT) $(VOBJS) $(RTC_OBJS) $(LCD_OBJS)


%.vobj: %.s
	$(VASM) $(VASM_FLAGS) $< -Fvobj -o $@

%.vobj: %.c
	$(VBCC) $(VCC_FLAGS) $< -o=$(TMP_VBCC_ASM)
	printf "\n\tinclude ../cregs.s\n" >> $(TMP_VBCC_ASM)
	$(VASM) $(VCA_FLAGS) $(TMP_VBCC_ASM) -Fvobj -o $@

clean:
	rm -f *.vobj $(TMP_VBCC_ASM) main.bin listing.txt
dump: main.bin
	cat listing.txt | grep -v ": local abs" | ack --color-match=red --passthru "0x.... [_a-zA-Z0-9]*: global .*"
