P=test

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
