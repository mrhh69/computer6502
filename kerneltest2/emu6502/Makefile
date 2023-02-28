CLANGFLAGS = -Wno-empty-body  -Og -g

main:   main.o emu.o term.o
	clang main.o emu.o term.o  -o main

main.o: main.c
	clang $(CLANGFLAGS)  -c main.c -o main.o
emu.o:  emu.c
	clang $(CLANGFLAGS)  -c emu.c  -o emu.o
term.o: term.c
	clang $(CLANGFLAGS)  -c term.c -o term.o




clean:
	rm *.o main
