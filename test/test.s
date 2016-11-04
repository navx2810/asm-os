.section .data

	Prompt: .asciz "Hello, world"

.section .text
.globl _start

_start:
	movl $50, %ecx
	leal Prompt, %edi
	movl $0, %eax
	call StrLen

EndProg:
	movl	$1,	%eax
	movl	$0,	%ebx
	int	$0x80


# Function to calculate the length of a terminated string
# EDI { String to calculate }
# EAX { Search Term }
# OUT => EAX { Count }
StrLen:
	pushl %ecx				# Save ECX state
	xorl %ecx, %ecx			# Reset ECX to zero
	dec %ecx				# Make ECX -1 to wrap around to max

	cld						# Clear Direction flag for search
	repne scasb				# Repeat till none
	not	%ecx				# Negate ECX to normalize the number
	dec %ecx				# Minus 1 to get the actual length

	movl %ecx, %eax			# Move the final value into EAX for return statement
	popl %ecx				# Return ECX to previous state
	ret
