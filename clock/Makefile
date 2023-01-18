SPI_DIR=../spi_lib/
RTC_OBJ=$(SPI_DIR)/rtc.vobj
RTC_MAKE=rtc.vobj


all: main.bin

#$(RTC_OBJ):
#always-submake so that the make is called even when the object is already built,
#to check for any change in the source files (which can only be done from sub-make)
always-submake:
	make -C $(SPI_DIR) $(RTC_MAKE)



VASM=vasm
VLINK=vlink
VBCC=vbcc
LD_SCRIPT=../test.ld
TMP_VBCC_ASM=/tmp/tmp_vbcc_asm.s

VASM_FLAGS=-wdc02 -I"../"
VCC_FLAGS=-c02 -O=413
VCA_FLAGS=-wdc02

SRCS=  $(wildcard *.s)
VOBJS= $(patsubst %.s,%.vobj,$(SRCS))
CSRCS= $(wildcard *.c)
VOBJS+=$(patsubst %.c,%.vobj,$(CSRCS))


main.bin:  $(VOBJS) $(RTC_OBJ)
	$(VLINK) -b rawbin1 -o main.bin  -T $(LD_SCRIPT) $(VOBJS) $(RTC_OBJ)


%.vobj: %.s
	$(VASM) $(VASM_FLAGS) $< -Fvobj -o $@

%.vobj: %.c
	$(VBCC) $(VCC_FLAGS) $< -o=$(TMP_VBCC_ASM)
	printf "\n\tinclude ../cregs.s\n" >> $(TMP_VBCC_ASM)
	$(VASM) $(VCA_FLAGS) $(TMP_VBCC_ASM) -Fvobj -o $@
	#rm $(TMP_VBCC_ASM)

clean:
	rm -f *.vobj $(TMP_VBCC_ASM) main.bin
	make -C $(SPI_DIR) clean
