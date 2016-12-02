# Program:	File opening, writing, reading
# Author:	Matt Fetterman
# Date:		XX/XX/2016

.section .data

	FileHandle:	.long	0
	ReadFH:		.long	0
	ReadName:	.asciz	"MyRead.txt"
	FileName:	.asciz	"MyFile.txt"
	
	buffer:		.asciz	"                    "
	.equ	bufflen,	.-buffer
	inputLen:	.long	0

	prompt:		.asciz "Name Please: "
	.equ	promptlen,	.-prompt
	
	.equ	O_RDWR,		02
	.equ	O_CREAT,	0100
	.equ	O_RDONLY,	00

.section .bss	
	# FileHandle could go here if you want
	.lcomm	words,	20*16	# Provide space for 20 words with 16 characters in each possible word

.section .text
.globl _start

_start:
	# Provide the prompt
	movl	$4, %eax
	movl	$1, %ebx
	movl	$prompt, %ecx		# leal, load effective address, without the $prompt, it becomes prompt
	movl	$promptlen, %edx
	int	$0x80
	
	# Read input into buffer
	movl	$3, %eax
	movl	$0, %ebx
	movl	$buffer, %ecx
	movl	$bufflen, %edx
	int	$0x80
	movl	%eax, inputLen

	# Open text file to write the name
	movl	$5, %eax
	movl	$FileName, %ebx
	movl	$(O_CREAT+O_RDWR), %ecx	# File Modes
	movl	$0644, %edx	# Permission
	int	$0x80
	
	test	%eax, %eax	# Check if there is an error
	js	EndProg		# Jump to handle error
	movl	%eax, FileHandle

	# Write name to file
	movl	$4, %eax
	movl	FileHandle, %ebx
	movl	$buffer, %ecx
	movl	inputLen, %edx
	int	$0x80
	
	#test	%eax, %eax	# Check if there was an error writing
	#js	ExitProg
	
	# Close the file
	movl	$6, %eax
	movl	FileHandle, %ebx
	int	$0x80
	
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
	
	movl	%eax, %edx	# Print the read 
	movl	$4, %eax
	movl	$1, %ebx
	leal	words, %ecx
	int	$0x80

				# Close the file
	movl	$6, %eax
	leal	ReadFH, %ebx
	int	$0x80
EndProg:
	movl	$1,	%eax
	movl	$0,	%ebx
	int	$0x80
