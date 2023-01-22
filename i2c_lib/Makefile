VASM=vasm

VASM_FLAGS=-wdc02 -I"../"

SRCS=  $(wildcard *.s)
VOBJS= $(patsubst %.s,%.vobj,$(SRCS))


all: $(VOBJS)

%.vobj: %.s
	$(VASM) $(VASM_FLAGS) $< -Fvobj -o $@

clean:
	rm -f *.vobj
