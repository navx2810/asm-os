P=check

x32:
	echo "\nI am running this program on a 64 bit compiler, so I pass flags to the assembler and linker to force 32 bit\nIf this doesn't work for you Dr. Yoas, try \"make all\"\n\n"
	as --gstabs+ --32 -o $(P).o $(P).s;
	ld -melf_i386 -o $(P) $(P).o
all:
	as --gstabs+ -o $(P).o $(P).s;
	ld -o $(P) $(P).o

run:
	./$(P)

debug:
	kdbg $(P)

clean:
	rm $(P).o $(P)
edit:
	vim $(P).s
