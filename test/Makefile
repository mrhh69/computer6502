LCD_DIR=../lcd_lib/
LCD_OBJS=$(LCD_DIR)/lcd.vobj

all: always-submake main.bin

always-submake:
	make -C $(LCD_DIR) $(LCD_MAKE)

VASM=vasm
VLINK=vlink
LD_SCRIPT=../test.ld
TMP_VBCC_ASM=/tmp/tmp_vbcc_asm.s

VASM_FLAGS=-wdc02 -I"../"
VLINK_FLAGS=-Mlisting.txt

SRCS=  $(wildcard *.s)
VOBJS= $(patsubst %.s,%.vobj,$(SRCS))


main.bin:  $(VOBJS)# $(RTC_OBJS) $(LCD_OBJS)
	$(VLINK) $(VLINK_FLAGS) -b rawbin1 -o main.bin -T $(LD_SCRIPT) $(VOBJS) $(LCD_OBJS)


%.vobj: %.s
	$(VASM) $(VASM_FLAGS) $< -Fvobj -o $@


clean:
	rm -f *.vobj $(TMP_VBCC_ASM) main.bin
	make -C $(LCD_DIR) clean

dump: main.bin
	cat listing.txt | grep -v ": local abs" | ack --color-match=red --passthru "0x.... [_a-zA-Z0-9]*: global .*"
