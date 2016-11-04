# Program:	<< WHAT DO I DO >>
# Author:	Matt Fetterman
# Date:		XX/XX/2016

.section .data

	SumBuf: .asciz "123456789"
	SumValue: .long 0
	NewSubBuf: .asciz "         "

	Divisor: .long 10

.section .bss

	.lcomm output, 10

.section .text
.globl _start

_start:

	leal SumBuf, %esi
	movl $0, %ebx
	movl $10, %ecx
Loop_BuildInt:
	lodsb				# Load the character in EAX
	subb $'0', %al		# Offset the ASCII number
	imull $10, %ebx		# Offset value by 10
	addl %eax, %ebx		# Add the popped number into EBX
	loop Loop_BuildInt
	movl %ebx, SumValue

	# Start conversion into string
	movl $6000, %eax
	leal NewSubBuf+9, %edi
	std
Loop_BuildStr:
	xor %edx, %edx		# Clear the Remainder

	divl	Divisor		# Divide by 10
	addl	$'0', %edx	# Offset the number to ASCII value
	xchg	%eax, %edx	# Swap the ASCII value into EAX for storing the byte into EDI
	stosb
	xchg	%eax, %edx

	cmpl	$0, %eax
	jne		Loop_BuildStr

	movl $4, %eax
	movl $1, %ebx
	leal NewSubBuf, %ecx
	movl $10, %edx
	int $0x80

EndProg:
	movl	$1,	%eax
	movl	$0,	%ebx
	int	$0x80

STRLEN:
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
