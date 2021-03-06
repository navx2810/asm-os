# Program:	Get input for two numbers and add them together
# Author:	Matt Fetterman
# Date:		11/04/2016

.section .data

	PlusSign:	.asciz " + "
	EqualsSign:	.asciz " = "
	APrompt:	.asciz "Please enter a positive number between 0 and 999999999 (999,999,999), without ',': "
	BPrompt:	.asciz "Please enter another positive number between 0 and 999999999 (999,999,999), without ',': "
	ErrorMsg:	.asciz "You entered bad input. Please try running the application again.\n"
	NewLine: 	.byte 10

	# NOTE: Ask Yoas why the hell two bytes next to each other can overwrite the last one when doing a { MOVB %al }, BLen. Changed them to int to solve problem temporarilly.
	ALen:		.int 0
	BLen:		.int 0

	ATotal:		.int 0
	BTotal:		.int 0
	Sum:		.int 0

	SumBuffer:	.asciz "            "	# 12 character buffer length, ASCIZ for '\0', Could place this in bss
	PadBufferLength: .int 0				# Keeps track of the total characters in the Buffer

.section .bss
	.lcomm A, 10
	.lcomm B, 10

	.lcomm PadBuffer, 13

.section .text
.globl _start

_start:

	leal	APrompt, %eax
	call	PrintTilNull

	# Read input into A
	leal	A, %eax			# Place Buffer into EAX for ReadInput
	call	ReadInput
	movl	%eax, ALen		# Move final count of input into ALen

	leal	BPrompt, %eax
	call	PrintTilNull

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
	leal	SumBuffer+11, %edi		# Place end of Buffer into EDI
	movl	%ebx, %eax				# Move total into EAX
	movl	$10, %ecx				# Put Divisor into ECX
	std								# Set direction to go from right-to-left
Loop_BuildStr:
	xor		%edx, %edx				# Clear EDX

	div		%ecx					# Divide EAX by 10
	addl	$'0', %edx				# Offset the remainder to get ASCII
	xchg	%eax, %edx				# Swap EAX and EDX to store byte
	stosb							# Store byte from AL
	xchg	%eax, %edx				# Swap EAX and EDX back

	cmpl	$0, %eax				# Check to see if Quotient is 0
	jne		Loop_BuildStr			# If not, do it again

	# Pad String Left
	movl	$12, %ecx		# Move 12 into ECX (max number available in buffer)
	leal	SumBuffer, %esi	# Move the Sum buffer that is right-aligned into ESI
	leal	PadBuffer, %edi	# Move the new buffer that will hold the left-aligned string in EDI
	cld						# Clear Direction to move right-to-left
Loop_Pad:
	xor		%eax, %eax		# Clear EAX
	lodsb					# Pop the first character from the Sum in ESI
	cmpl	$32, %eax		# Check to see if it is a ' ' character
	je Loop_Pad_Cont
	stosb					# If it is not a ' ' character, store the character in EDI
Loop_Pad_Cont:
	loop Loop_Pad
	movl	$0, %eax		# Move a '\0' into EAX
	stosb					# Push '\0' in EDI

	# Get Pad Buffer Length by checking ' ' count in Right-padded buffer
	leal	SumBuffer, %edi
	movl	$32, %eax		# Use ' ' as a search term
	movl	$13, %ecx		# Move the max value of buffer which is 13 including '\0'
	repe	scasb			# Repeat while the character is a ' '
	movl	%ecx, PadBufferLength

	# Prepare to print sum statement

	movl	$4, %eax		# Write
	movl	$1, %ebx		# Stdout

	pushl	%eax			# Save the 4 for write
	leal	A, %ecx
	movl	ALen, %edx
	dec		%edx			# Offset the count by -1 to ignore '\0'
	int		$0x80
	popl	%eax			# Restore the 4 for write

	pushl	%eax			# Save the 4 for write
	leal	PlusSign, %ecx
	movl	$4, %edx
	int		$0x80
	popl	%eax			# Restore the 4 for write

	pushl	%eax			# Save the 4 for write
	leal	B, %ecx
	movl	BLen, %edx
	dec		%edx			# Offset the count by -1 to ignore '\0'
	int		$0x80
	popl	%eax			# Restore the 4 for write

	pushl	%eax			# Save the 4 for write
	leal	EqualsSign, %ecx
	movl	$4, %edx
	int		$0x80
	popl	%eax			# Restore the 4 for write

	pushl	%eax			# Save the 4 for write
	leal	PadBuffer, %ecx
	movl	PadBufferLength, %edx
	int		$0x80
	popl	%eax			# Restore the 4 for write

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
	repne scasb				# Search string for AL
	subl $256, %ecx			# Subtract arbitrary value
	not %ecx				# Negate the value to remove sign

	movl %ecx, %eax			# Move the final value into EAX for return statement

	popl %ecx				# Return ECX to previous state
	ret

# Function to print a string while looking for a '\0' value
# EAX { String to print }
PrintTilNull:
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
	pushl	%esi

	movl	%eax, %ecx		# Move buffer into ECX
	movl	$3, %eax		# Read
	movl	$0, %ebx		# Stdin
	movl	$10, %edx		# With a length of 10
	int 	$0x80

	pushl	%eax			# Store the length of the input

	movl	%ecx, %esi		# Move buffer into ESI
	movl 	%eax, %ecx		# Move length to counter
	dec		%ecx			# Offset for null-byte
Loop_CheckForNonNumber:					# Check for a non-number character in input
	lodsb								# Pop the character in ESI into EAX
	cmpb	$'0', %al					# Check if the character is less than '0'
	jl		Loop_CheckForNonNumber_Bad
	cmpb	$'9', %al					# Check if character is greater than '9'
	jg		Loop_CheckForNonNumber_Bad
	loop	Loop_CheckForNonNumber		# If it is a number, continue the loop
	jmp		Loop_CheckForNonNumber_End	# When the loop is done, finish up
Loop_CheckForNonNumber_Bad:
	leal	ErrorMsg, %eax				# Load error prompt and display it
	call	PrintTilNull
	call	EndProg
Loop_CheckForNonNumber_End:
	popl	%eax			# Restore the length of input
	popl	%esi
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

	xor		%ebx, %ebx	# Clear EBX (total value) to zero
LoopInt:
	lodsb				# Load the character into AL
	subb	$'0', %al	# Offset the ASCII number
	imull	$10, %ebx	# Offset the total by 10 to make room for number
	addl	%eax, %ebx	# Place number into the total
	loop	LoopInt

	popl 	%eax
	ret
