# Program:	Read a file, sort its contents and write it out to a new file
# Author:	Matt Fetterman
# Date:		12/02/2016

.section .data

	SortedFlag:	.int	0	# This is a variable used in the sort to check if the entire array was fully sorted or needs another run through the bubble sort

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
	.lcomm	words,	20*16	# Provide space for 20 words with 16 characters in each possible word
	.lcomm	upper_case_words,	20*16	# Provides a buffer to store the upper-case version into

.section .text
.globl _start

_start:

ReadFile:
	movl	$5, %eax
	leal	ReadName, %ebx
	movl	$O_RDONLY, %ecx
	movl	$0644, %edx	# Pass chmod permissions for 6-4-4
	int		$0x80

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
	inc		%ebx			# Increase the string length counter
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
	movl	%edx, PointerCounter	# Store the counter for pointers

TransformUpperCase:
	leal	words, %esi				# Place the original buffer into the source
	leal	upper_case_words, %edi	# Place the new buffer into destination
	movl	ReadLen, %ecx			# Place length for counter
TUC_Loop:
	lodsb							# Pop off the character
	cmpb	$'a', %al				# If it is below 'a', continue
	jl		TUC_Cont
	cmpb	$'z', %al				# If it is above 'z', continue
	jg		TUC_Cont

	subb	$32, %al				# Otherwise, offset the lowercase value by 32 to get upper-case value

TUC_Cont:
	stosb							# Place new value into new buffer
	loop	TUC_Loop

Cmp_PreLoop:
	xor		%edx, %edx				# Reset the index counter to 0
	movl	$0, SortedFlag			# Set the sort flag to 0
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

	cld						# Clear direction flag
	repe	cmpsb			# Repeat while equal
	js		Cmp_Cont	# If the first array item was smaller, dont swap, just continue
	jne		Cmp_Swap	# If they were not equal, EDI must have been smaller and needs swapped

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

	movl	$1, SortedFlag				# Toggle the sorted flag to let the sort know to run again

Cmp_Cont:
	popl	%ecx		# Pop Pointer Loop Counter
	inc		%edx		# Move Index counter to next array element
	loop	Cmp_Loop

	mov		SortedFlag, %eax	# Place the sort check flag into EAX
	test	%eax, %eax			# Test if the flag is zero
	jnz		Cmp_PreLoop			# If not, run the sort again

	movl	PointerCounter, %ecx	# Store the counter for main print loop
TestPrintSortedArray:
	pushl	%ecx					# Push the main counter

	movl	%ecx, %edx				# Move it to EDX
	subl	PointerCounter, %edx	# Subtract the value from the max pointer counter value to get offset
	not		%edx					# Negate and increment to get value
	inc		%edx
	movl	Pointers(, %edx, 4), %edi	# Move the pointer at the counter location to EDI

	movl	$'\n', %eax				# Place '\n' as the search term for repne
	movl	$20, %ecx				# Place 20 as the maximum word length
	cld								# Clear direction flag
	repne	scasb					# Repeatedly scan till '\n' is found
	subl	$20, %ecx				# Calculate the length of the string by offsetting max
	not		%ecx					# Negative and increment to get actual value
	inc		%ecx

	movl	%ecx, PointersLen(, %edx, 4)	# Store the length into Pointers Length { Needed since the array positions were switched around earlier. }

	movl	$4, %eax	# Prepare to print the value at the pointer
	movl	$1, %ebx
	movl	Pointers(, %edx, 4), %edx	# Move pointers to EDX for switch
	xchg	%ecx, %edx					# Flip the registers

	int		$0x80

	popl	%ecx		# Pop the pointer counter for loop
	loop	TestPrintSortedArray

WriteToFile:
	# Open text file to write the name
	movl	$5, %eax
	movl	$FileName, %ebx
	movl	$(O_CREAT+O_RDWR), %ecx	# File Modes
	movl	$0644, %edx	# Permissions
	int		$0x80

	test	%eax, %eax	# Check if there is an error
	js		EndProg		# Jump to handle error
	movl	%eax, FileHandle	# Store the handler

	movl	PointerCounter, %ecx	# Place the length of the pointers for looping

	movl	FileHandle, %ebx	# Store the handle in EBX
Write_Loop:
	pushl	%ecx		# Store counter
	subl	PointerCounter, %ecx	# Subtract the counter from the amount of pointers
	not		%ecx					# Negate and increment to get value
	inc		%ecx
	movl	PointersLen(, %ecx, 4), %edx	# Move the length of the pointer into EDX for print
	movl	Pointers(, %ecx, 4), %ecx		# Move the pointer into ECX for print
	movl	$4, %eax
	int		$0x80

	test	%eax, %eax	# Check if there was an error writing
	js		Finish
	popl	%ecx		# Pop the pointer counter
	loop	Write_Loop

Finish:
	# Close the file
	movl	$6, %eax
	movl	FileHandle, %ebx
	int		$0x80

EndProg:
	movl	$1,	%eax
	movl	$0,	%ebx
	int		$0x80
