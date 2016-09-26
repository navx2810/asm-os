P=check

x32:
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
