SPI_DIR=../spi_lib/
RTC_OBJ=$(SPI_DIR)/rtc.vobj
RTC_MAKE=rtc.vobj


all: main.bin

$(RTC_OBJ):
	make -C $(SPI_DIR) $(RTC_MAKE)



VASM=vasm
VLINK=vlink
LD_SCRIPT=../test.ld


main.bin:  main.vobj $(RTC_OBJ)
	$(VLINK) -b rawbin1 -o main.bin  -T $(LD_SCRIPT) main.vobj $(RTC_OBJ)

main.vobj: main.s
	$(VASM) -Fvobj main.s -o main.vobj
