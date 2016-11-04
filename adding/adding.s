# Program:	Get input for two numbers and add them together
# Author:	Matt Fetterman
# Date:		11/04/2016

.section .data

	PlusSign:	.asciz " + "
	EqualsSign:	.asciz " = "
	APrompt:	.asciz "Please enter a positive number between 0 and 999999999 (999,999,999), without ',': "
	BPrompt:	.asciz "Please enter another positive number between 0 and 999999999 (999,999,999), without ',': "
	NewLine: 	.byte 10

	# NOTE: Ask Yoas why the hell two bytes next to each other can overwrite the last one when doing a { MOVB %al }, BLen. Changed them to int to solve problem temporarilly.
	ALen:		.int 0
	BLen:		.int 0

	ATotal:		.int 0
	BTotal:		.int 0
	Sum:		.int 0

	SumBuffer:	.asciz "            "	# 12 character buffer length, ASCIZ for \0

.section .bss
	.lcomm A, 10
	.lcomm B, 10

.section .text
.globl _start

_start:

	leal	APrompt, %eax
	call	PrintWithSearch

	# Read input into A
	leal	A, %eax			# Place Buffer into EAX for ReadInput
	call	ReadInput
	movl	%eax, ALen		# Move final count of input into ALen

	#call	PrintNL
	leal	BPrompt, %eax
	call	PrintWithSearch

	# Read input into B
	leal	B, %eax			# Place Buffer into EAX for ReadInput
	call	ReadInput
	movl	%eax, BLen		# Move final count of input into BLen

	# Begin calculating the Integer values for A
	leal	A, %esi			# Move buffer into ESI
	movl	ALen, %ecx		# Move buffer length into ECX
	call	ToInt
	movl	%ebx, ATotal

	# Begin calculating the Integer values for B
	leal	B, %esi			# Move buffer into ESI
	movl	BLen, %ecx		# Move buffer length into ECX
	call	ToInt
	movl	%ebx, BTotal

	# Sum up the totals
	addl	ATotal, %ebx
	movl	%ebx, Sum

	# Build Sum String
	leal	SumBuffer+11, %edi
	movl	%ebx, %eax
	movl	$10, %ecx	# Divisor
	std
Loop_BuildStr:
	xor		%edx, %edx

	div		%ecx
	addl	$'0', %edx
	xchg	%eax, %edx
	stosb
	xchg	%eax, %edx

	cmpl	$0, %eax
	jne		Loop_BuildStr

	# Prepare to print sum statement

	movl	$4, %eax		# Write
	movl	$1, %ebx		# Stdout

	leal	A, %ecx
	movl	ALen, %edx
	dec		%edx
	int		$0x80

	leal	PlusSign, %ecx
	movl	$4, %edx
	int		$0x80

	leal	B, %ecx
	movl	BLen, %edx
	dec		%edx
	int		$0x80

	leal	EqualsSign, %ecx
	movl	$4, %edx
	int		$0x80

	leal	SumBuffer, %ecx
	movl	$12, %edx
	int		$0x80

	leal	NewLine, %ecx
	movl	$1, %edx
	int		$0x80

EndProg:
	movl	$1,	%eax
	movl	$0,	%ebx
	int		$0x80


# Function to calculate the length of a terminated string
# EDI { String to calculate }
# EAX { Search Term }
# OUT => EAX { Count }
StrLen:
	pushl %ecx				# Save ECX state

	movl $256, %ecx			# Arbitrary max number for search
	cld						# Clear Direction flag for search
	repne scasb				# Repeat till none
	subl $256, %ecx			# Subtract arbitrary value
	not %ecx				# Negate the value to remove sign
	inc %ecx				# Add one to replace the lost bit

	movl %ecx, %eax			# Move the final value into EAX for return statement

	popl %ecx				# Return ECX to previous state
	ret

# Function to print a string while looking for a \0 value
# EAX { String to print }
PrintWithSearch:
	pushal				# Store all register states

	movl	%eax, %edi	# Move the string into EDI for StrLen
	movl	%eax, %esi 	# Store the string into the Source for later
	movl 	$0, %eax	# Search term for '\0'
	call 	StrLen

	# Prepare for Print
	movl	%eax, %edx	# Move length from StrLen into EDX
	movl	$4, %eax	# Print
	movl	$1, %ebx	# Console
	movl	%esi, %ecx	# Put source string into ECX
	int		$0x80

	popal				# Pop all register states
	ret

# Function to print a single New Line character
# No Parameters
PrintNL:
	pushal				# Store all register states

	movl	$4, %eax	# Write
	movl	$1, %ebx	# Console
	leal	NewLine, %ecx	# New Line Character
	movl	$1, %edx	# Length of 1
	int		$0x80

	popal				# Pop all register states
	ret

# Function to read input into a buffer
# EAX { Buffer Variable }
# OUT => EAX { Length of input entered }
ReadInput:
	pushl	%ebx
	pushl	%ecx
	pushl	%edx

	movl	%eax, %ecx		# Move buffer into ECX
	movl	$3, %eax		# Read
	movl	$0, %ebx		# Stdin
	movl	$10, %edx		# With a length of 10
	int 	$0x80

	popl	%edx
	popl	%ecx
	popl	%ebx
	ret

# Function to convert input to Integer
# ESI { Input Buffer }
# ECX { Buffer Length }
# OUT => EBX { Integer value }
ToInt:
	pushl	%eax
	dec		%ecx		# Offset the counter by -1 to account for new-line

	xorl	%ebx, %ebx	# Set EBX (total value) to zero
LoopInt:
	lodsb				# Load the character into EAX
	subb	$'0', %al	# Offset the ASCII number
	imull	$10, %ebx	# Offset the total by 10 to make room for number
	addl	%eax, %ebx	# Place number into the total
	loop	LoopInt

	popl 	%eax
	ret
