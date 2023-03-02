
VASM=vasm
VLINK=vlink
VBCC=vbcc
LD_SCRIPT=user.ld
TMP_VBCC_ASM=/tmp/tmp_vbcc_asm.s

VASM_FLAGS=-wdc02 -I"../" -I"../../"
VLINK_FLAGS=-Mlisting.txt
VLINK_FLAGS+=-T$(LD_SCRIPT)
# 1+2+4+8+16+32+128+256
VCC_FLAGS=-c02 -O=447
VCA_FLAGS=-wdc02 -opt-branch

SRCS=  $(wildcard *.s)
VOBJS= $(patsubst %.s,%.vobj,$(SRCS))
CSRCS= $(wildcard *.c)
VOBJS+=$(patsubst %.c,%.vobj,$(CSRCS))


S_ADDR?=0

out.bin: $(VOBJS)
	$(VLINK) $(VLINK_FLAGS) -Ttext $(S_ADDR)   -b rawbin1 -o out.bin    $(VOBJS)

%.vobj: %.s
	$(VASM) $(VASM_FLAGS) $< -Fvobj -o $@

%.vobj: %.c
	$(VBCC) $(VCC_FLAGS) $< -o=$(TMP_VBCC_ASM)
	printf "\n\tinclude ../cregs.s\n" >> $(TMP_VBCC_ASM)
	$(VASM) $(VCA_FLAGS) $(TMP_VBCC_ASM) -Fvobj -o $@

clean:
	rm -f *.vobj *.o65 $(TMP_VBCC_ASM) out.bin listing.txt
dump: main.bin
	cat listing.txt | grep -v ": local abs" | ack --color-match=red --passthru "0x.... [_a-zA-Z0-9]*: global .*"
