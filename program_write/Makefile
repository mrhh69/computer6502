


all: hello_world.bin main
	cp main ../program

hello_world.bin: HelloWorld.s
	vasm -wdc02 -I"../" HelloWorld.s -Fbin -o hello_world.bin

main: main.c
	gcc main.c -o main
