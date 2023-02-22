

#MV BECAUSE MAC DOESN'T RUN MY PROGRAM (KILLED: 9) WHEN IT'S CP'd
all: hello_world.bin main
	mv main ../program

hello_world.bin: hello_world.s
	make -C ../lcd_lib/
	vasm -wdc02 -I"../" hello_world.s -Fvobj -o hello_world.vobj
	vlink -Mlisting.txt -T ../test.ld hello_world.vobj ../lcd_lib/lcd.vobj  -b rawbin1 -o hello_world.bin
	rm hello_world.vobj

main: main.c
	gcc main.c -o main
