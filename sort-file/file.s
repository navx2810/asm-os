# Program:	File opening, writing, reading
# Author:	Matt Fetterman
# Date:		XX/XX/2016

.section .data

	Pointers:	.int 	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0		# 20 zero'ed pointers to potential words
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
	js	EndProg
	movl	%eax, ReadFH	# Read File Handle

	movl	$3, %eax	# Read from the file
	movl	ReadFH, %ebx
	leal	words, %ecx
	movl	$20*16, %edx	# File won't try to read things that are not there
	int	$0x80
	
	test	%eax, %eax
	js	EndProg
	movl	%eax, ReadLen

	movl	%eax, %edx	# Print the read 
	movl	$4, %eax
	movl	$1, %ebx
	leal	words, %ecx
	int	$0x80

				# Close the file
	movl	$6, %eax
	leal	ReadFH, %ebx
	int	$0x80

	# { Start calculating word locations }
	xor	%eax, %eax
	leal	words, %esi
	movl	$1, %ebx	# Clear EBX, used for conditional move
	movl	ReadLen, %ecx
	movl	PointerCounter, %edx
	movl	%esi, Pointers(, %edx, 4)
	inc	%edx
Loop:
	lodsb
	cmpb	$'\n', %al
	jne	Loop_Cont
	lodsb			# Offset the pointer to point to the next character following the '\n'
	dec	%ecx		# Decrease the loop counter to account for advanced pointer
	inc	%edx
	movl	%esi, Pointers(, %edx, 4)
Loop_Cont:
	test	%ecx, %ecx
	cmove	%ebx, %ecx
	loop	Loop

EndProg:
	movl	$1,	%eax
	movl	$0,	%ebx
	int	$0x80
