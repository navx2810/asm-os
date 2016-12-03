# Program:	Read a file, sort its contents and write it back out to a new file
# Author:	Matt Fetterman
# Date:		12/02/2016

.section .data

	Pointers:	.int 	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0		# 20 zeroed pointers to potential words
	PointersLen:	.int 	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0		# 20 zeroed pointers to potential word lengths for convenience
	PointerCounter:	.int	0	# Number of words counted

	FileHandle:	.long	0
	ReadFH:		.long	0
	ReadName:	.asciz	"words.txt"
	FileName:	.asciz	"sorted.txt"
	ReadLen:	.int	0

	.equ	O_RDWR,		02
	.equ	O_CREAT,	0100
	.equ	O_RDONLY,	00

.section .bss
	# FileHandle could go here if you want
	.lcomm	words,	20*16	# Provide space for 20 words with 16 characters in each possible word

.section .text
.globl _start

_start:
	# Open text file to write the name
	#movl	$5, %eax
	#movl	$FileName, %ebx
	#movl	$(O_CREAT+O_RDWR), %ecx	# File Modes
	#movl	$0644, %edx	# Permission
	#int	$0x80

	#test	%eax, %eax	# Check if there is an error
	#js	EndProg		# Jump to handle error
	#movl	%eax, FileHandle

	# Write name to file
	#movl	$4, %eax
	#movl	FileHandle, %ebx
	#movl	$buffer, %ecx
	#movl	inputLen, %edx
	#int	$0x80

	#test	%eax, %eax	# Check if there was an error writing
	#js	EndProg

	# Close the file
	#movl	$6, %eax
	#movl	FileHandle, %ebx
	#int	$0x80

ReadFile:
	movl	$5, %eax
	leal	ReadName, %ebx
	movl	$O_RDONLY, %ecx
	movl	$0644, %edx	# Pass chmod permissions for 6-4-4
	int	$0x80

	test	%eax, %eax
	js		EndProg
	movl	%eax, ReadFH	# Read File Handle

	movl	$3, %eax	# Read from the file
	movl	ReadFH, %ebx
	leal	words, %ecx
	movl	$20*16, %edx	# File wont try to read things that are not there
	int		$0x80

	test	%eax, %eax
	js		EndProg
	movl	%eax, ReadLen

	movl	%eax, %edx	# Print the read
	movl	$4, %eax
	movl	$1, %ebx
	leal	words, %ecx
	int		$0x80

				# Close the file
	movl	$6, %eax
	leal	ReadFH, %ebx
	int		$0x80

	# { Start calculating word locations }
	xor		%eax, %eax		# Clear AL for LODSB
	leal	words, %esi		# Put words into the source index
	xor		%ebx, %ebx		# Reset EBX to use for string length counter
	movl	ReadLen, %ecx		# Place the length of the files contents into ECX
	movl	PointerCounter, %edx	# Place counter into EDX for offset
	movl	%esi, Pointers(, %edx, 4)	# Put the first location into the slot[0] for the array of pointers
Loop:
	lodsb				# Pop the first character off into AL
	inc	%ebx			# Increase the string length counter
	cmpb	$'\n', %al	# Check to see if the character is a new-line
	jne		Loop_Cont
	movl	%ebx, PointersLen(, %edx, 4)
	inc		%edx		# Increment the Pointer Counter number
	movl	%esi, Pointers(, %edx, 4)	# Place the next word pointer into the Array
	xor		%ebx, %ebx		# Reset string length to zero
Loop_Cont:
	test	%ecx, %ecx	# Check the counter variable if it will hit out of range for the loop use
	jz		Loop_End	# If it equals 0, jump to end
	js		Loop_End	# If it is negative, jump to end
	loop	Loop
Loop_End:
	movl	%edx, PointerCounter
#	{ Print the test array }
	xor		%edx, %edx

	movl	$2, %edx
	movl	$4, %eax
	movl	$1, %ebx
	movl	Pointers(, %edx, 4), %ecx
	movl	PointersLen(, %edx, 4), %edx
	int		$0x80

	xor		%edx, %edx				# Reset the index counter to 0
	movl	PointerCounter, %ecx	# Put the total number of words into the counter
	dec		%ecx					# Offset the counter to end at n-1 elements
Cmp_Loop:
	movl	Pointers(, %edx, 4), %esi	# Get result at Pointers[EDX]
	inc		%edx						# Increment counter to get next value
	movl	Pointers(, %edx, 4), %edi	# Get result at Pointers[EDX+1]

	pushl	%ecx		# Store Pointer Loop Counter

	movl	PointersLen(, %edx, 4), %ebx	# Move the length of EDX+1 into EBX
	dec		%edx
	movl	PointersLen(, %edx, 4), %ecx	# Move the length of EDX into EAX

	cmp		%ecx, %ebx		# Check which length is greater
	cmovbe	%ebx, %ecx		# Move the lesser one into ECX for REP counter

	movl	$1, %eax
	cld
	repe	cmpsb
	js		Cmp_Cont	# If the first array item was smaller, dont swap, just continue
	jne		Cmp_Swap	# If they were not equal, EDI must have been smaller and needs swapped

	movl	PointersLen(, %edx, 4), %eax
	inc		%edx
	movl	PointersLen(, %edx, 4), %ebx
	dec		%edx

	cmp		%eax, %ebx
	js		Cmp_Cont	# If the value is smaller, move on
	jz		Cmp_Cont	# If the value is equal, also move on

	jmp		Cmp_Swap

	jmp		Cmp_Cont
Cmp_Swap:
	movl	Pointers(, %edx, 4), %esi	# Replace with result at Pointers[EDX]
	inc		%edx						# Increment counter to get next value
	movl	Pointers(, %edx, 4), %edi	# Replace with result at Pointers[EDX+1]
	dec		%edx

	xchg	%edi, Pointers(, %edx, 4)	# Move the pointer at EDI to the smaller location
	inc		%edx
	xchg	%esi, Pointers(, %edx, 4)	# Move the pointer at ESI to the larger location
	dec		%edx

Cmp_Cont:
	popl	%ecx		# Pop Pointer Loop Counter
	inc		%edx		# Move Index counter to next array element
	loop	Cmp_Loop

EndProg:
	movl	$1,	%eax
	movl	$0,	%ebx
	int		$0x80
